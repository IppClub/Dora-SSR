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
function normalizeReasoningEffort(value) -- 788
	if type(value) ~= "string" then -- 788
		return nil -- 789
	end -- 789
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value)) -- 790
	return normalized ~= "" and normalized or nil -- 791
end -- 791
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
function ____exports.safeJsonEncode(value, indent, sortKeys, escapeSlash, maxDepth) -- 113
	return json.encode( -- 114
		sanitizeJSONValue(value), -- 115
		indent, -- 116
		sortKeys, -- 117
		escapeSlash, -- 118
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
	local charLen = utf8.len(text) -- 154
	if not charLen or charLen <= 0 then -- 154
		return 0 -- 155
	end -- 155
	local otherChars = #text - charLen -- 156
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 157
	return math.max(1, tokens) -- 158
end -- 152
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
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 501
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 511
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 512
	if stopToken == nil then -- 512
		stopToken = {stopped = false} -- 518
	end -- 518
	return __TS__New( -- 519
		__TS__Promise, -- 519
		function(____, resolve, reject) -- 519
			local requestId = 0 -- 520
			local settled = false -- 521
			local function finishResolve(text) -- 522
				if settled then -- 522
					return -- 523
				end -- 523
				settled = true -- 524
				resolve(nil, text) -- 525
			end -- 522
			local function finishReject(err) -- 527
				if settled then -- 527
					return -- 528
				end -- 528
				settled = true -- 529
				reject(nil, err) -- 530
			end -- 527
			Director.systemScheduler:schedule(function() -- 532
				if not settled then -- 532
					if stopToken.stopped then -- 532
						if requestId ~= 0 then -- 532
							HttpClient:cancel(requestId) -- 536
							requestId = 0 -- 537
						end -- 537
						finishReject("request cancelled") -- 539
						return true -- 540
					end -- 540
					return false -- 542
				end -- 542
				return true -- 544
			end) -- 532
			Director.systemScheduler:schedule(once(function() -- 546
				emit( -- 547
					"LLM_IN", -- 547
					table.concat( -- 547
						__TS__ArrayMap( -- 547
							messages, -- 547
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 547
						), -- 547
						"\n" -- 547
					) -- 547
				) -- 547
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 548
				if jsonStr ~= nil then -- 548
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 550
					requestId = receiver and HttpClient:post( -- 555
						url, -- 556
						headers, -- 556
						jsonStr, -- 556
						requestTimeout, -- 556
						function(data) -- 556
							if stopToken.stopped then -- 556
								return true -- 557
							end -- 557
							return receiver(data) -- 558
						end, -- 556
						function(data) -- 559
							requestId = 0 -- 560
							if data ~= nil then -- 560
								finishResolve(data) -- 562
							else -- 562
								finishReject("failed to get http response") -- 564
							end -- 564
						end -- 559
					) or HttpClient:post( -- 559
						url, -- 567
						headers, -- 567
						jsonStr, -- 567
						requestTimeout, -- 567
						function(data) -- 567
							requestId = 0 -- 568
							if stopToken.stopped then -- 568
								finishReject("request cancelled") -- 570
								return -- 571
							end -- 571
							if data ~= nil then -- 571
								finishResolve(data) -- 574
							else -- 574
								finishReject("failed to get http response") -- 576
							end -- 576
						end -- 567
					) -- 567
					if requestId == 0 then -- 567
						finishReject("failed to schedule http request") -- 580
					elseif stopToken.stopped then -- 580
						HttpClient:cancel(requestId) -- 582
						requestId = 0 -- 583
						finishReject("request cancelled") -- 584
					end -- 584
				else -- 584
					finishReject(err) -- 587
				end -- 587
			end)) -- 546
		end -- 519
	) -- 519
end -- 501
function ____exports.createSSEJSONParser(opts) -- 597
	local buffer = "" -- 602
	local eventDataLines = {} -- 603
	local function flushEventIfAny() -- 605
		if #eventDataLines == 0 then -- 605
			return -- 606
		end -- 606
		local dataPayload = table.concat(eventDataLines, "\n") -- 608
		eventDataLines = {} -- 609
		if dataPayload == "[DONE]" then -- 609
			local ____opt_1 = opts.onDone -- 609
			if ____opt_1 ~= nil then -- 609
				____opt_1(dataPayload) -- 612
			end -- 612
			return -- 613
		end -- 613
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 616
		if err == nil then -- 616
			opts.onJSON(obj, dataPayload) -- 618
		else -- 618
			local ____opt_3 = opts.onError -- 618
			if ____opt_3 ~= nil then -- 618
				____opt_3(err, {raw = dataPayload}) -- 620
			end -- 620
		end -- 620
	end -- 605
	local function feed(chunk) -- 624
		buffer = buffer .. chunk -- 625
		while true do -- 625
			do -- 625
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 628
				if nl < 0 then -- 628
					break -- 629
				end -- 629
				local line = __TS__StringSlice(buffer, 0, nl) -- 631
				buffer = __TS__StringSlice(buffer, nl + 1) -- 632
				if __TS__StringEndsWith(line, "\r") then -- 632
					line = string.sub(line, 1, -2) -- 634
				end -- 634
				if line == "" then -- 634
					flushEventIfAny() -- 637
					goto __continue160 -- 638
				end -- 638
				if __TS__StringStartsWith(line, ":") then -- 638
					goto __continue160 -- 642
				end -- 642
				if __TS__StringStartsWith(line, "data:") then -- 642
					local v = string.sub(line, 6) -- 645
					if __TS__StringStartsWith(v, " ") then -- 645
						v = string.sub(v, 2) -- 646
					end -- 646
					eventDataLines[#eventDataLines + 1] = v -- 647
					goto __continue160 -- 648
				end -- 648
			end -- 648
			::__continue160:: -- 648
		end -- 648
	end -- 624
	local function ____end() -- 653
		if #buffer > 0 then -- 653
			local line = buffer -- 655
			buffer = "" -- 656
			if __TS__StringEndsWith(line, "\r") then -- 656
				line = string.sub(line, 1, -2) -- 657
			end -- 657
			if __TS__StringStartsWith(line, "data:") then -- 657
				local v = string.sub(line, 6) -- 660
				if __TS__StringStartsWith(v, " ") then -- 660
					v = string.sub(v, 2) -- 661
				end -- 661
				eventDataLines[#eventDataLines + 1] = v -- 662
			end -- 662
		end -- 662
		flushEventIfAny() -- 665
	end -- 653
	return {feed = feed, ["end"] = ____end} -- 668
end -- 597
local function normalizeContextWindow(value) -- 763
	if type(value) == "number" then -- 763
		return math.max( -- 765
			64000, -- 765
			math.floor(value) -- 765
		) -- 765
	end -- 765
	return 64000 -- 767
end -- 763
local function normalizeSupportsFunctionCalling(value) -- 770
	return value == nil or value == nil or value ~= 0 -- 771
end -- 770
local function normalizeLLMTemperature(value) -- 774
	if type(value) == "number" then -- 774
		return math.max( -- 776
			0, -- 776
			math.min(2, value) -- 776
		) -- 776
	end -- 776
	return 0.1 -- 778
end -- 774
local function normalizeLLMMaxTokens(value) -- 781
	if type(value) == "number" then -- 781
		return math.max( -- 783
			1, -- 783
			math.floor(value) -- 783
		) -- 783
	end -- 783
	return 8192 -- 785
end -- 781
function ____exports.getActiveLLMConfig() -- 794
	local rows = DB:query("select * from LLMConfig", true) -- 795
	local records = {} -- 796
	if rows and #rows > 1 then -- 796
		do -- 796
			local i = 1 -- 798
			while i < #rows do -- 798
				local record = {} -- 799
				do -- 799
					local c = 0 -- 800
					while c < #rows[i + 1] do -- 800
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 801
						c = c + 1 -- 800
					end -- 800
				end -- 800
				records[#records + 1] = record -- 803
				i = i + 1 -- 798
			end -- 798
		end -- 798
	end -- 798
	local config = __TS__ArrayFind( -- 806
		records, -- 806
		function(____, r) return r.active ~= 0 end -- 806
	) -- 806
	if not config then -- 806
		return {success = false, message = "no active LLM config"} -- 808
	end -- 808
	local url = config.url -- 808
	local model = config.model -- 808
	local api_key = config.api_key -- 808
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 808
		return {success = false, message = "got invalude LLM config"} -- 812
	end -- 812
	return { -- 814
		success = true, -- 815
		config = { -- 816
			url = url, -- 817
			model = model, -- 818
			apiKey = api_key, -- 819
			contextWindow = normalizeContextWindow(config.context_window), -- 820
			temperature = normalizeLLMTemperature(config.temperature), -- 821
			maxTokens = normalizeLLMMaxTokens(config.max_tokens), -- 822
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort), -- 823
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 824
		} -- 824
	} -- 824
end -- 794
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 829
	local callEvent -- 835
	if event.id ~= nil then -- 835
		local id = event.id -- 837
		callEvent = { -- 838
			id = nil, -- 839
			onData = function(data) -- 840
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 841
				return event.stopToken.stopped -- 842
			end, -- 840
			onCancel = function(reason) -- 844
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 845
			end, -- 844
			onDone = function() -- 847
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 848
			end -- 847
		} -- 847
	else -- 847
		callEvent = event -- 852
	end -- 852
	local ____callEvent_5 = callEvent -- 854
	local onData = ____callEvent_5.onData -- 854
	local onDone = ____callEvent_5.onDone -- 854
	local ____callEvent_6 = callEvent -- 855
	local onCancel = ____callEvent_6.onCancel -- 855
	local config = llmConfig or (function() -- 856
		local configRes = ____exports.getActiveLLMConfig() -- 857
		if not configRes.success then -- 857
			if onCancel then -- 857
				onCancel(configRes.message) -- 859
			end -- 859
			return nil -- 860
		end -- 860
		return configRes.config -- 862
	end)() -- 856
	if not config then -- 856
		return {success = false, message = "no active LLM config"} -- 865
	end -- 865
	local url = config.url -- 865
	local model = config.model -- 865
	local apiKey = config.apiKey -- 865
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 868
	if fitted.trimmed then -- 868
		____exports.Log( -- 870
			"Warn", -- 870
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 870
		) -- 870
	end -- 870
	local stopLLM = false -- 872
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 873
		local result = onData(obj) -- 875
		if result then -- 875
			stopLLM = result -- 876
		end -- 876
	end}); -- 874
	(function() -- 879
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 879
			local ____try = __TS__AsyncAwaiter(function() -- 879
				local ____array_8 = __TS__SparseArrayNew( -- 879
					fitted.messages, -- 881
					url, -- 881
					apiKey, -- 881
					model, -- 881
					options, -- 881
					true, -- 881
					function(data) -- 881
						if stopLLM then -- 881
							if onCancel then -- 881
								onCancel("LLM Stopped") -- 884
								onCancel = nil -- 885
							end -- 885
							return true -- 887
						end -- 887
						parser.feed(data) -- 889
						return false -- 890
					end -- 881
				) -- 881
				local ____temp_7 -- 891
				if event.stopToken ~= nil then -- 891
					____temp_7 = event.stopToken -- 891
				else -- 891
					____temp_7 = nil -- 891
				end -- 891
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 891
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 881
				parser["end"]() -- 892
				if onDone then -- 892
					onDone(result) -- 894
				end -- 894
			end) -- 894
			__TS__Await(____try.catch( -- 880
				____try, -- 880
				function(____, e) -- 880
					stopLLM = true -- 897
					if onCancel then -- 897
						onCancel(tostring(e)) -- 899
						onCancel = nil -- 900
					end -- 900
				end -- 900
			)) -- 900
		end) -- 900
	end)() -- 879
	return {success = true} -- 904
end -- 829
local function mergeStreamToolCall(target, delta) -- 907
	if type(delta.id) == "string" and delta.id ~= "" then -- 907
		target.id = delta.id -- 909
	end -- 909
	if type(delta.type) == "string" and delta.type ~= "" then -- 909
		target.type = delta.type -- 912
	end -- 912
	if delta["function"] then -- 912
		if target["function"] == nil then -- 912
			target["function"] = {} -- 915
		end -- 915
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 915
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 917
		end -- 917
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 917
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 920
		end -- 920
	end -- 920
end -- 907
local function isToolCallComplete(tc) -- 925
	if type(tc.id) ~= "string" or tc.id == "" then -- 925
		return false -- 926
	end -- 926
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then -- 926
		return false -- 927
	end -- 927
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then -- 927
		return false -- 928
	end -- 928
	local args = tc["function"].arguments -- 929
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then -- 929
		return false -- 930
	end -- 930
	local decoded = ____exports.safeJsonDecode(args) -- 931
	return decoded ~= nil -- 932
end -- 925
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds) -- 935
	local delta = choice.delta or ({}) -- 936
	local fullMessage = choice.message or ({}) -- 937
	local message = acc.message -- 938
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 939
	if type(role) == "string" and role ~= "" then -- 939
		message.role = role -- 943
	end -- 943
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 945
	if type(content) == "string" and content ~= "" then -- 945
		message.content = (message.content or "") .. content -- 949
	end -- 949
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 951
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 951
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 955
	end -- 955
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 957
	if toolCalls and #toolCalls > 0 then -- 957
		if message.tool_calls == nil then -- 957
			message.tool_calls = {} -- 961
		end -- 961
		do -- 961
			local i = 0 -- 962
			while i < #toolCalls do -- 962
				local item = toolCalls[i + 1] -- 963
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 964
				local ____message_tool_calls_9, ____temp_10 = message.tool_calls, index + 1 -- 964
				if ____message_tool_calls_9[____temp_10] == nil then -- 964
					____message_tool_calls_9[____temp_10] = {} -- 967
				end -- 967
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 968
				if onToolCallReady and emittedToolCallIds then -- 968
					local tc = message.tool_calls[index + 1] -- 970
					if tc and isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then -- 970
						emittedToolCallIds[tc.id] = true -- 972
						onToolCallReady(tc) -- 973
					end -- 973
				end -- 973
				i = i + 1 -- 962
			end -- 962
		end -- 962
	end -- 962
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 962
		acc.finish_reason = choice.finish_reason -- 979
	end -- 979
end -- 935
local function buildStreamResponse(states, model, id, created, object, providerError) -- 983
	local indexes = __TS__ArraySort( -- 991
		__TS__ArrayFilter( -- 991
			__TS__ArrayMap( -- 991
				__TS__ObjectKeys(states), -- 991
				function(____, key) return __TS__Number(key) end -- 992
			), -- 992
			function(____, index) return __TS__NumberIsFinite(index) end -- 993
		), -- 993
		function(____, a, b) return a - b end -- 994
	) -- 994
	return { -- 995
		id = id, -- 996
		created = created, -- 997
		object = object, -- 998
		model = model, -- 999
		choices = __TS__ArrayMap( -- 1000
			indexes, -- 1000
			function(____, index) -- 1000
				local state = states[index] -- 1001
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 1002
			end -- 1000
		), -- 1000
		error = providerError -- 1013
	} -- 1013
end -- 983
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady) -- 1017
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1017
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1025
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1026
		local resolvedConfig = config or (function() -- 1029
			local configRes = ____exports.getActiveLLMConfig() -- 1030
			if not configRes.success then -- 1030
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 1032
				return nil -- 1033
			end -- 1033
			return configRes.config -- 1035
		end)() -- 1029
		if not resolvedConfig then -- 1029
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1029
		end -- 1029
		local url = resolvedConfig.url -- 1029
		local model = resolvedConfig.model -- 1029
		local apiKey = resolvedConfig.apiKey -- 1029
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1041
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0 -- 1042
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset") -- 1043
		local ____model_15 = model -- 1046
		local ____url_16 = url -- 1046
		local ____temp_17 = #messages -- 1046
		local ____tostring_12 = tostring -- 1046
		local ____options_max_tokens_11 = options.max_tokens -- 1046
		if ____options_max_tokens_11 == nil then -- 1046
			____options_max_tokens_11 = "unset" -- 1046
		end -- 1046
		local ____tostring_12_result_18 = ____tostring_12(____options_max_tokens_11) -- 1046
		local ____tostring_14 = tostring -- 1046
		local ____options_temperature_13 = options.temperature -- 1046
		if ____options_temperature_13 == nil then -- 1046
			____options_temperature_13 = "unset" -- 1046
		end -- 1046
		____exports.Log( -- 1046
			"Info", -- 1046
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_15) .. " url=") .. ____url_16) .. " messages=") .. tostring(____temp_17)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_12_result_18) .. " temperature=") .. ____tostring_14(____options_temperature_13)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1046
		) -- 1046
		if stopToken and stopToken.stopped then -- 1046
			local reason = stopToken.reason or "request cancelled" -- 1048
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 1049
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1049
		end -- 1049
		local ____try = __TS__AsyncAwaiter(function() -- 1049
			local states = {} -- 1053
			local emittedToolCallIds = {} -- 1054
			local responseId = nil -- 1055
			local responseCreated = nil -- 1056
			local responseObject = nil -- 1057
			local providerError -- 1058
			local httpChunkCount = 0 -- 1059
			local rawStreamBytes = 0 -- 1060
			local rawStreamPreview = "" -- 1061
			local sseJSONChunkCount = 0 -- 1062
			local choiceJSONChunkCount = 0 -- 1063
			local emptyChoicesChunkCount = 0 -- 1064
			local missingChoicesChunkCount = 0 -- 1065
			local parseErrorCount = 0 -- 1066
			local doneChunkSeen = false -- 1067
			local lastJSONPreview = "" -- 1068
			local parser = ____exports.createSSEJSONParser({ -- 1069
				onJSON = function(obj, raw) -- 1070
					sseJSONChunkCount = sseJSONChunkCount + 1 -- 1071
					lastJSONPreview = previewText(raw, 500) -- 1072
					if not obj or type(obj) ~= "table" then -- 1072
						return -- 1074
					end -- 1074
					local chunk = obj -- 1076
					if chunk.error then -- 1076
						providerError = chunk.error -- 1078
						____exports.Log( -- 1079
							"Warn", -- 1079
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 1079
						) -- 1079
						return -- 1080
					end -- 1080
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1082
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1083
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1084
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1085
					if not __TS__ArrayIsArray(chunk.choices) then -- 1085
						missingChoicesChunkCount = missingChoicesChunkCount + 1 -- 1087
						if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1087
							____exports.Log( -- 1089
								"Warn", -- 1089
								"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300) -- 1089
							) -- 1089
						end -- 1089
					elseif #choices == 0 then -- 1089
						emptyChoicesChunkCount = emptyChoicesChunkCount + 1 -- 1092
						if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then -- 1092
							____exports.Log( -- 1094
								"Warn", -- 1094
								"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300) -- 1094
							) -- 1094
						end -- 1094
					else -- 1094
						choiceJSONChunkCount = choiceJSONChunkCount + 1 -- 1097
					end -- 1097
					do -- 1097
						local i = 0 -- 1099
						while i < #choices do -- 1099
							local choice = choices[i + 1] -- 1100
							local index = type(choice.index) == "number" and choice.index or i -- 1101
							if states[index] == nil then -- 1101
								states[index] = {index = index, message = {role = "assistant"}} -- 1102
							end -- 1102
							mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds) -- 1106
							i = i + 1 -- 1099
						end -- 1099
					end -- 1099
					if onChunk ~= nil then -- 1099
						onChunk( -- 1108
							buildStreamResponse( -- 1109
								states, -- 1109
								model, -- 1109
								responseId, -- 1109
								responseCreated, -- 1109
								responseObject, -- 1109
								providerError -- 1109
							), -- 1109
							{ -- 1110
								id = chunk.id or "", -- 1111
								created = chunk.created or 0, -- 1112
								object = chunk.object or "", -- 1113
								model = chunk.model or model, -- 1114
								choices = choices -- 1115
							} -- 1115
						) -- 1115
					end -- 1115
				end, -- 1070
				onDone = function() -- 1119
					doneChunkSeen = true -- 1120
				end, -- 1119
				onError = function(err, context) -- 1122
					parseErrorCount = parseErrorCount + 1 -- 1123
					____exports.Log( -- 1124
						"Warn", -- 1124
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1124
					) -- 1124
				end -- 1122
			}) -- 1122
			__TS__Await(postLLM( -- 1127
				fitted.messages, -- 1127
				url, -- 1127
				apiKey, -- 1127
				model, -- 1127
				options, -- 1127
				true, -- 1127
				function(data) -- 1127
					if stopToken and stopToken.stopped then -- 1127
						return true -- 1128
					end -- 1128
					httpChunkCount = httpChunkCount + 1 -- 1129
					rawStreamBytes = rawStreamBytes + #data -- 1130
					if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then -- 1130
						rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview) -- 1132
					end -- 1132
					parser.feed(data) -- 1134
					return false -- 1135
				end, -- 1127
				stopToken -- 1136
			)) -- 1136
			parser["end"]() -- 1137
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then -- 1137
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview)) -- 1139
				if rawResponse and type(rawResponse) == "table" then -- 1139
					local rawResponseObj = rawResponse -- 1141
					if rawResponseObj.error then -- 1141
						providerError = rawResponseObj.error -- 1143
						lastJSONPreview = previewText( -- 1144
							normalizeLLMJSONResponse(rawStreamPreview), -- 1144
							500 -- 1144
						) -- 1144
						____exports.Log( -- 1145
							"Warn", -- 1145
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500) -- 1145
						) -- 1145
					end -- 1145
				end -- 1145
			end -- 1145
			local response = buildStreamResponse( -- 1149
				states, -- 1149
				model, -- 1149
				responseId, -- 1149
				responseCreated, -- 1149
				responseObject, -- 1149
				providerError -- 1149
			) -- 1149
			local choiceCount = response.choices and #response.choices or 0 -- 1150
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false") -- 1151
			____exports.Log( -- 1152
				"Info", -- 1152
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats -- 1152
			) -- 1152
			if not response.choices or #response.choices == 0 then -- 1152
				local providerMessage = providerError and providerError.message or "" -- 1154
				local providerType = providerError and providerError.type or "" -- 1155
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1156
				local details = table.concat( -- 1159
					__TS__ArrayFilter( -- 1159
						{providerType, providerCode}, -- 1159
						function(____, part) return part ~= "" end -- 1159
					), -- 1159
					"/" -- 1159
				) -- 1159
				local rawPreview = previewText( -- 1160
					____exports.sanitizeUTF8(rawStreamPreview), -- 1160
					1200 -- 1160
				) -- 1160
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or "" -- 1161
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON -- 1162
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON) -- 1165
				return ____awaiter_resolve(nil, {success = false, message = message, raw = rawStreamPreview}) -- 1165
			end -- 1165
			return ____awaiter_resolve(nil, {success = true, response = response}) -- 1165
		end) -- 1165
		__TS__Await(____try.catch( -- 1052
			____try, -- 1052
			function(____, e) -- 1052
				if stopToken and stopToken.stopped then -- 1052
					local reason = stopToken.reason or "request cancelled" -- 1178
					____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1179
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1179
				end -- 1179
				____exports.Log( -- 1182
					"Error", -- 1182
					"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1182
				) -- 1182
				return ____awaiter_resolve( -- 1182
					nil, -- 1182
					{ -- 1183
						success = false, -- 1183
						message = tostring(e) -- 1183
					} -- 1183
				) -- 1183
			end -- 1183
		)) -- 1183
	end) -- 1183
end -- 1017
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1187
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1187
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1193
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1194
		local resolvedConfig = config or (function() -- 1197
			local configRes = ____exports.getActiveLLMConfig() -- 1198
			if not configRes.success then -- 1198
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1200
				return nil -- 1201
			end -- 1201
			return configRes.config -- 1203
		end)() -- 1197
		if not resolvedConfig then -- 1197
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1197
		end -- 1197
		local url = resolvedConfig.url -- 1197
		local model = resolvedConfig.model -- 1197
		local apiKey = resolvedConfig.apiKey -- 1197
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1209
		____exports.Log( -- 1210
			"Info", -- 1210
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1210
		) -- 1210
		if stopToken and stopToken.stopped then -- 1210
			local reason = stopToken.reason or "request cancelled" -- 1212
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1213
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1213
		end -- 1213
		local ____try = __TS__AsyncAwaiter(function() -- 1213
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1217
				fitted.messages, -- 1217
				url, -- 1217
				apiKey, -- 1217
				model, -- 1217
				options, -- 1217
				false, -- 1217
				nil, -- 1217
				stopToken -- 1217
			))) -- 1217
			local normalizedRaw = normalizeLLMJSONResponse(raw) -- 1218
			____exports.Log( -- 1219
				"Info", -- 1219
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "") -- 1219
			) -- 1219
			local response, err = ____exports.safeJsonDecode(normalizedRaw) -- 1220
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1220
				local rawPreview = previewText(raw) -- 1222
				____exports.Log( -- 1223
					"Error", -- 1223
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1223
				) -- 1223
				return ____awaiter_resolve( -- 1223
					nil, -- 1223
					{ -- 1224
						success = false, -- 1225
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1226
						raw = raw -- 1227
					} -- 1227
				) -- 1227
			end -- 1227
			local responseObj = response -- 1230
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1231
			____exports.Log( -- 1232
				"Info", -- 1232
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1232
			) -- 1232
			if not responseObj.choices or #responseObj.choices == 0 then -- 1232
				local providerError = responseObj.error -- 1234
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1235
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1238
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1241
				local details = table.concat( -- 1244
					__TS__ArrayFilter( -- 1244
						{providerType, providerCode}, -- 1244
						function(____, part) return part ~= "" end -- 1244
					), -- 1244
					"/" -- 1244
				) -- 1244
				local rawPreview = previewText(raw, 400) -- 1245
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1246
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1249
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 1249
			end -- 1249
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 1249
		end) -- 1249
		__TS__Await(____try.catch( -- 1216
			____try, -- 1216
			function(____, e) -- 1216
				if stopToken and stopToken.stopped then -- 1216
					local reason = stopToken.reason or "request cancelled" -- 1262
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1263
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1263
				end -- 1263
				____exports.Log( -- 1266
					"Error", -- 1266
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1266
				) -- 1266
				return ____awaiter_resolve( -- 1266
					nil, -- 1266
					{ -- 1267
						success = false, -- 1267
						message = tostring(e) -- 1267
					} -- 1267
				) -- 1267
			end -- 1267
		)) -- 1267
	end) -- 1267
end -- 1187
return ____exports -- 1187