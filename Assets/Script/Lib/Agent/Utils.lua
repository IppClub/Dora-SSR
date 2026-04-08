-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
local HttpClient = ____Dora.HttpClient -- 2
local DB = ____Dora.DB -- 2
local emit = ____Dora.emit -- 2
local DoraLog = ____Dora.Log -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local App = ____Dora.App -- 2
local LOG_LEVEL = App.debugging and 3 or 2 -- 4
function ____exports.setLogLevel(level) -- 5
	LOG_LEVEL = level -- 6
end -- 5
local LLM_TIMEOUT = 600 -- 9
function ____exports.setLLMTimeout(timeout) -- 10
	LLM_TIMEOUT = timeout -- 11
end -- 10
local LLM_STREAM_TIMEOUT = 60 -- 13
____exports.Log = function(____type, msg) -- 15
	if LOG_LEVEL < 1 then -- 15
		return -- 16
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 16
		return -- 17
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 17
		return -- 18
	end -- 18
	DoraLog(____type, msg) -- 19
end -- 15
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 46
local TOOL_CALL_ID_COUNTER = 0 -- 47
local function toBase36(value) -- 49
	if value <= 0 then -- 49
		return "0" -- 50
	end -- 50
	local remaining = math.floor(value) -- 51
	local out = "" -- 52
	while remaining > 0 do -- 52
		local digit = remaining % 36 -- 54
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 55
		remaining = math.floor(remaining / 36) -- 56
	end -- 56
	return out -- 58
end -- 49
function ____exports.createLocalToolCallId() -- 61
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 62
	local timePart = toBase36(os.time()) -- 63
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 64
	return ("tc" .. timePart) .. counterPart -- 65
end -- 61
local function previewText(text, maxLen) -- 73
	if maxLen == nil then -- 73
		maxLen = 200 -- 73
	end -- 73
	if not text then -- 73
		return "" -- 74
	end -- 74
	local compact = __TS__StringReplace( -- 75
		__TS__StringReplace(text, "\r", "\\r"), -- 75
		"\n", -- 75
		"\\n" -- 75
	) -- 75
	if #compact <= maxLen then -- 75
		return compact -- 76
	end -- 76
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 77
end -- 73
function ____exports.sanitizeUTF8(text) -- 80
	if not text then -- 80
		return "" -- 81
	end -- 81
	local remaining = text -- 82
	local output = "" -- 83
	while remaining ~= "" do -- 83
		local len, invalidPos = utf8.len(remaining) -- 85
		if len ~= nil then -- 85
			output = output .. remaining -- 87
			break -- 88
		end -- 88
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 90
		if badPos > 1 then -- 90
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 92
		end -- 92
		remaining = __TS__StringSubstring(remaining, badPos) -- 94
	end -- 94
	return output -- 96
end -- 80
local function sanitizeJSONValue(value) -- 99
	if type(value) == "string" then -- 99
		return ____exports.sanitizeUTF8(value) -- 100
	end -- 100
	if __TS__ArrayIsArray(value) then -- 100
		return __TS__ArrayMap( -- 102
			value, -- 102
			function(____, item) return sanitizeJSONValue(item) end -- 102
		) -- 102
	end -- 102
	if value and type(value) == "table" then -- 102
		local result = {} -- 105
		for key in pairs(value) do -- 106
			result[key] = sanitizeJSONValue(value[key]) -- 107
		end -- 107
		return result -- 109
	end -- 109
	return value -- 111
end -- 99
function ____exports.safeJsonEncode(value, indent, sortKeys, escapeSlash, maxDepth) -- 114
	return json.encode( -- 115
		sanitizeJSONValue(value), -- 116
		indent, -- 117
		sortKeys, -- 118
		escapeSlash, -- 119
		maxDepth -- 120
	) -- 120
end -- 114
function ____exports.safeJsonDecode(text) -- 124
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 125
	if value == nil then -- 125
		return value, err -- 127
	end -- 127
	return sanitizeJSONValue(value), err -- 129
end -- 124
local function utf8TakeHead(text, maxChars) -- 132
	if maxChars <= 0 or text == "" then -- 132
		return "" -- 133
	end -- 133
	local nextPos = utf8.offset(text, maxChars + 1) -- 134
	if nextPos == nil then -- 134
		return text -- 135
	end -- 135
	return string.sub(text, 1, nextPos - 1) -- 136
end -- 132
local function utf8TakeTail(text, maxChars) -- 139
	if maxChars <= 0 or text == "" then -- 139
		return "" -- 140
	end -- 140
	local charLen = utf8.len(text) -- 141
	if charLen == nil or charLen <= maxChars then -- 141
		return text -- 142
	end -- 142
	local startChar = math.max(1, charLen - maxChars + 1) -- 143
	local startPos = utf8.offset(text, startChar) -- 144
	if startPos == nil then -- 144
		return text -- 145
	end -- 145
	return string.sub(text, startPos) -- 146
end -- 139
function ____exports.estimateTextTokens(text) -- 149
	if not text then -- 149
		return 0 -- 150
	end -- 150
	local charLen = utf8.len(text) -- 151
	if not charLen or charLen <= 0 then -- 151
		return 0 -- 152
	end -- 152
	local otherChars = #text - charLen -- 153
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 154
	return math.max(1, tokens) -- 155
end -- 149
local function estimateMessagesTokens(messages) -- 158
	local total = 0 -- 159
	do -- 159
		local i = 0 -- 160
		while i < #messages do -- 160
			local message = messages[i + 1] -- 161
			total = total + 8 -- 162
			total = total + ____exports.estimateTextTokens(message.role or "") -- 163
			total = total + ____exports.estimateTextTokens(message.content or "") -- 164
			total = total + ____exports.estimateTextTokens(message.name or "") -- 165
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 166
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 167
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 168
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 169
			i = i + 1 -- 160
		end -- 160
	end -- 160
	return total -- 171
end -- 158
local function estimateOptionsTokens(options) -- 174
	local text = ____exports.safeJsonEncode(options) -- 175
	return text and ____exports.estimateTextTokens(text) or 0 -- 176
end -- 174
local function getReservedOutputTokens(options, contextWindow) -- 179
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 180
	if explicitMax > 0 then -- 180
		return math.max(256, explicitMax) -- 185
	end -- 185
	return math.max( -- 186
		1024, -- 186
		math.floor(contextWindow * 0.2) -- 186
	) -- 186
end -- 179
local function getInputTokenBudget(messages, options, config) -- 189
	local contextWindow = math.max(4000, config.contextWindow) -- 190
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 191
	local optionTokens = estimateOptionsTokens(options) -- 192
	local structuralOverhead = math.max(256, #messages * 16) -- 193
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 194
end -- 189
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 197
	if budgetTokens <= 0 or text == "" then -- 197
		return "" -- 198
	end -- 198
	local estimated = ____exports.estimateTextTokens(text) -- 199
	if estimated <= budgetTokens then -- 199
		return text -- 200
	end -- 200
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 201
	local targetChars = math.max( -- 202
		200, -- 202
		math.floor(budgetTokens * charsPerToken) -- 202
	) -- 202
	local keepHead = math.max( -- 203
		0, -- 203
		math.floor(targetChars * 0.35) -- 203
	) -- 203
	local keepTail = math.max(0, targetChars - keepHead) -- 204
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 205
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 206
	return (head .. "\n...\n") .. tail -- 207
end -- 197
local function isXMLWhitespaceChar(ch) -- 210
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 211
end -- 210
local function findLineStart(value, from) -- 214
	local i = from -- 215
	while i >= 0 do -- 215
		if __TS__StringAccess(value, i) == "\n" then -- 215
			return i + 1 -- 217
		end -- 217
		i = i - 1 -- 218
	end -- 218
	return 0 -- 220
end -- 214
local function findLastLiteral(text, needle) -- 223
	if needle == "" then -- 223
		return #text -- 224
	end -- 224
	local last = -1 -- 225
	local from = 0 -- 226
	while from <= #text - #needle do -- 226
		local pos = (string.find( -- 228
			text, -- 228
			needle, -- 228
			math.max(from + 1, 1), -- 228
			true -- 228
		) or 0) - 1 -- 228
		if pos < 0 then -- 228
			break -- 229
		end -- 229
		last = pos -- 230
		from = pos + 1 -- 231
	end -- 231
	return last -- 233
end -- 223
local function unwrapXMLRawText(text) -- 236
	local trimmed = __TS__StringTrim(text) -- 237
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 237
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 239
	end -- 239
	return text -- 241
end -- 236
local function readSimpleXMLTagName(source, openStart, openEnd) -- 244
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 245
	if rawTag == "" then -- 245
		return { -- 247
			success = false, -- 247
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 247
		} -- 247
	end -- 247
	local selfClosing = false -- 249
	local tagText = rawTag -- 250
	if __TS__StringEndsWith(tagText, "/") then -- 250
		selfClosing = true -- 252
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 253
	end -- 253
	local tagName = "" -- 255
	do -- 255
		local i = 0 -- 256
		while i < #tagText do -- 256
			local ch = __TS__StringAccess(tagText, i) -- 257
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 257
				break -- 258
			end -- 258
			tagName = tagName .. ch -- 259
			i = i + 1 -- 256
		end -- 256
	end -- 256
	if tagName == "" then -- 256
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 262
	end -- 262
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 264
end -- 244
local function findMatchingXMLClose(source, tagName, contentStart) -- 267
	local sameOpenPrefix = "<" .. tagName -- 268
	local sameCloseToken = ("</" .. tagName) .. ">" -- 269
	local pos = contentStart -- 270
	local depth = 1 -- 271
	while pos < #source do -- 271
		do -- 271
			local lt = (string.find( -- 273
				source, -- 273
				"<", -- 273
				math.max(pos + 1, 1), -- 273
				true -- 273
			) or 0) - 1 -- 273
			if lt < 0 then -- 273
				break -- 274
			end -- 274
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 274
				local cdataEnd = (string.find( -- 276
					source, -- 276
					"]]>", -- 276
					math.max(lt + 9 + 1, 1), -- 276
					true -- 276
				) or 0) - 1 -- 276
				if cdataEnd < 0 then -- 276
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 277
				end -- 277
				pos = cdataEnd + 3 -- 278
				goto __continue68 -- 279
			end -- 279
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 282
					source, -- 282
					"-->",
					math.max(lt + 4 + 1, 1), -- 282
					true -- 282
				) or 0) - 1 -- 282
				if commentEnd < 0 then -- 282
					return {success = false, message = "invalid xml: unterminated comment"} -- 283
				end -- 283
				pos = commentEnd + 3 -- 284
				goto __continue68 -- 285
			end -- 285
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 285
				depth = depth - 1 -- 288
				if depth == 0 then -- 288
					return {success = true, closeStart = lt} -- 289
				end -- 289
				pos = lt + #sameCloseToken -- 290
				goto __continue68 -- 291
			end -- 291
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 291
				local openEnd = (string.find( -- 294
					source, -- 294
					">", -- 294
					math.max(lt + 1, 1), -- 294
					true -- 294
				) or 0) - 1 -- 294
				if openEnd < 0 then -- 294
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 295
				end -- 295
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 296
				if not tagInfo.success then -- 296
					return tagInfo -- 297
				end -- 297
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 297
					depth = depth + 1 -- 299
				end -- 299
				pos = openEnd + 1 -- 301
				goto __continue68 -- 302
			end -- 302
			local genericEnd = (string.find( -- 304
				source, -- 304
				">", -- 304
				math.max(lt + 1, 1), -- 304
				true -- 304
			) or 0) - 1 -- 304
			if genericEnd < 0 then -- 304
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 305
			end -- 305
			pos = genericEnd + 1 -- 306
		end -- 306
		::__continue68:: -- 306
	end -- 306
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 308
end -- 267
function ____exports.extractXMLFromText(text) -- 311
	local source = __TS__StringTrim(text) -- 312
	local function extractFencedBlock(fence) -- 313
		if not __TS__StringStartsWith(source, fence) then -- 313
			return nil -- 314
		end -- 314
		local firstLineEnd = (string.find( -- 315
			source, -- 315
			"\n", -- 315
			math.max(1, 1), -- 315
			true -- 315
		) or 0) - 1 -- 315
		if firstLineEnd < 0 then -- 315
			return nil -- 316
		end -- 316
		local searchPos = firstLineEnd + 1 -- 317
		local closingFencePositions = {} -- 318
		while searchPos < #source do -- 318
			local ____end = (string.find( -- 320
				source, -- 320
				"```", -- 320
				math.max(searchPos + 1, 1), -- 320
				true -- 320
			) or 0) - 1 -- 320
			if ____end < 0 then -- 320
				break -- 321
			end -- 321
			local lineStart = findLineStart(source, ____end - 1) -- 322
			local lineEnd = (string.find( -- 323
				source, -- 323
				"\n", -- 323
				math.max(____end + 1, 1), -- 323
				true -- 323
			) or 0) - 1 -- 323
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 324
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 324
				closingFencePositions[#closingFencePositions + 1] = ____end -- 326
			end -- 326
			searchPos = ____end + 1 -- 328
		end -- 328
		do -- 328
			local i = #closingFencePositions - 1 -- 330
			while i >= 0 do -- 330
				do -- 330
					local closingFencePos = closingFencePositions[i + 1] -- 331
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 332
					if afterFence ~= "" then -- 332
						goto __continue89 -- 333
					end -- 333
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 334
				end -- 334
				::__continue89:: -- 334
				i = i - 1 -- 330
			end -- 330
		end -- 330
		return nil -- 336
	end -- 313
	local xmlBlock = extractFencedBlock("```xml") -- 338
	if xmlBlock ~= nil then -- 338
		return xmlBlock -- 339
	end -- 339
	local genericBlock = extractFencedBlock("```") -- 340
	if genericBlock ~= nil then -- 340
		return genericBlock -- 341
	end -- 341
	return source -- 342
end -- 311
function ____exports.parseSimpleXMLChildren(source) -- 345
	local result = {} -- 346
	local pos = 0 -- 347
	while pos < #source do -- 347
		do -- 347
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 347
				pos = pos + 1 -- 349
			end -- 349
			if pos >= #source then -- 349
				break -- 350
			end -- 350
			if __TS__StringAccess(source, pos) ~= "<" then -- 350
				return { -- 352
					success = false, -- 352
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 352
				} -- 352
			end -- 352
			if __TS__StringStartsWith(source, "</", pos) then -- 352
				return { -- 355
					success = false, -- 355
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 355
				} -- 355
			end -- 355
			local openEnd = (string.find( -- 357
				source, -- 357
				">", -- 357
				math.max(pos + 1, 1), -- 357
				true -- 357
			) or 0) - 1 -- 357
			if openEnd < 0 then -- 357
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 359
			end -- 359
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 361
			if not tagInfo.success then -- 361
				return tagInfo -- 362
			end -- 362
			if tagInfo.selfClosing then -- 362
				result[tagInfo.tagName] = "" -- 364
				pos = openEnd + 1 -- 365
				goto __continue94 -- 366
			end -- 366
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 368
			if not closeRes.success then -- 368
				return closeRes -- 369
			end -- 369
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 370
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 371
			pos = closeRes.closeStart + #closeToken -- 372
		end -- 372
		::__continue94:: -- 372
	end -- 372
	return {success = true, obj = result} -- 374
end -- 345
function ____exports.parseXMLObjectFromText(text, rootTag) -- 377
	local xmlText = ____exports.extractXMLFromText(text) -- 378
	local rootOpen = ("<" .. rootTag) .. ">" -- 379
	local rootClose = ("</" .. rootTag) .. ">" -- 380
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 381
	local ____end = findLastLiteral(xmlText, rootClose) -- 382
	if start < 0 or ____end < start then -- 382
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 384
	end -- 384
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 386
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 387
	if beforeRoot ~= "" or afterRoot ~= "" then -- 387
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 389
	end -- 389
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 391
	return ____exports.parseSimpleXMLChildren(rootContent) -- 392
end -- 377
function ____exports.fitMessagesToContext(messages, options, config) -- 395
	local cloned = __TS__ArrayMap( -- 402
		messages, -- 402
		function(____, message) return __TS__ObjectAssign({}, message) end -- 402
	) -- 402
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 403
	local originalTokens = estimateMessagesTokens(cloned) -- 404
	if originalTokens <= budgetTokens then -- 404
		return { -- 406
			messages = cloned, -- 407
			trimmed = false, -- 408
			originalTokens = originalTokens, -- 409
			fittedTokens = originalTokens, -- 410
			budgetTokens = budgetTokens -- 411
		} -- 411
	end -- 411
	local function roleOverhead(message) -- 415
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 415
	end -- 415
	local fixedOverhead = 0 -- 416
	local contentIndexes = {} -- 417
	do -- 417
		local i = 0 -- 418
		while i < #cloned do -- 418
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 419
			contentIndexes[#contentIndexes + 1] = i -- 420
			i = i + 1 -- 418
		end -- 418
	end -- 418
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 422
	if #contentIndexes == 1 then -- 422
		local idx = contentIndexes[1] -- 424
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 425
		local fittedTokens = estimateMessagesTokens(cloned) -- 426
		return { -- 427
			messages = cloned, -- 428
			trimmed = true, -- 429
			originalTokens = originalTokens, -- 430
			fittedTokens = fittedTokens, -- 431
			budgetTokens = budgetTokens -- 432
		} -- 432
	end -- 432
	local nonSystemIndexes = {} -- 436
	local systemIndexes = {} -- 437
	do -- 437
		local i = 0 -- 438
		while i < #cloned do -- 438
			if cloned[i + 1].role == "system" then -- 438
				systemIndexes[#systemIndexes + 1] = i -- 439
			else -- 439
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 440
			end -- 440
			i = i + 1 -- 438
		end -- 438
	end -- 438
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 438
	__TS__SparseArrayPush( -- 438
		____array_0, -- 438
		table.unpack(systemIndexes) -- 442
	) -- 442
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 442
	local remainingContentBudget = contentBudget -- 443
	do -- 443
		local i = #priorityIndexes - 1 -- 444
		while i >= 0 do -- 444
			local idx = priorityIndexes[i + 1] -- 445
			local message = cloned[idx + 1] -- 446
			local minBudget = message.role == "system" and 96 or 192 -- 447
			local target = math.max( -- 448
				minBudget, -- 448
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 448
			) -- 448
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 449
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 450
			remainingContentBudget = math.max(0, remainingContentBudget) -- 451
			i = i - 1 -- 444
		end -- 444
	end -- 444
	local fittedTokens = estimateMessagesTokens(cloned) -- 454
	if fittedTokens > budgetTokens then -- 454
		do -- 454
			local i = 0 -- 456
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 456
				local idx = priorityIndexes[i + 1] -- 457
				local message = cloned[idx + 1] -- 458
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 459
				local excess = fittedTokens - budgetTokens -- 460
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 461
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 462
				fittedTokens = estimateMessagesTokens(cloned) -- 463
				i = i + 1 -- 456
			end -- 456
		end -- 456
	end -- 456
	if fittedTokens > budgetTokens then -- 456
		do -- 456
			local i = 0 -- 467
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 467
				do -- 467
					local idx = priorityIndexes[i + 1] -- 468
					if cloned[idx + 1].role == "system" then -- 468
						goto __continue124 -- 469
					end -- 469
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 470
					fittedTokens = estimateMessagesTokens(cloned) -- 471
				end -- 471
				::__continue124:: -- 471
				i = i + 1 -- 467
			end -- 467
		end -- 467
	end -- 467
	return { -- 474
		messages = cloned, -- 475
		trimmed = true, -- 476
		originalTokens = originalTokens, -- 477
		fittedTokens = fittedTokens, -- 478
		budgetTokens = budgetTokens -- 479
	} -- 479
end -- 395
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 483
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 493
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 494
	if stopToken == nil then -- 494
		stopToken = {stopped = false} -- 500
	end -- 500
	return __TS__New( -- 501
		__TS__Promise, -- 501
		function(____, resolve, reject) -- 501
			local requestId = 0 -- 502
			local settled = false -- 503
			local function finishResolve(text) -- 504
				if settled then -- 504
					return -- 505
				end -- 505
				settled = true -- 506
				resolve(nil, text) -- 507
			end -- 504
			local function finishReject(err) -- 509
				if settled then -- 509
					return -- 510
				end -- 510
				settled = true -- 511
				reject(nil, err) -- 512
			end -- 509
			Director.systemScheduler:schedule(function() -- 514
				if not settled then -- 514
					if stopToken.stopped then -- 514
						if requestId ~= 0 then -- 514
							HttpClient:cancel(requestId) -- 518
							requestId = 0 -- 519
						end -- 519
						finishReject("request cancelled") -- 521
						return true -- 522
					end -- 522
					return false -- 524
				end -- 524
				return true -- 526
			end) -- 514
			Director.systemScheduler:schedule(once(function() -- 528
				emit( -- 529
					"LLM_IN", -- 529
					table.concat( -- 529
						__TS__ArrayMap( -- 529
							messages, -- 529
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 529
						), -- 529
						"\n" -- 529
					) -- 529
				) -- 529
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 530
				if jsonStr ~= nil then -- 530
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 532
					requestId = receiver and HttpClient:post( -- 537
						url, -- 538
						headers, -- 538
						jsonStr, -- 538
						requestTimeout, -- 538
						function(data) -- 538
							if stopToken.stopped then -- 538
								return true -- 539
							end -- 539
							return receiver(data) -- 540
						end, -- 538
						function(data) -- 541
							requestId = 0 -- 542
							if data ~= nil then -- 542
								finishResolve(data) -- 544
							else -- 544
								finishReject("failed to get http response") -- 546
							end -- 546
						end -- 541
					) or HttpClient:post( -- 541
						url, -- 549
						headers, -- 549
						jsonStr, -- 549
						requestTimeout, -- 549
						function(data) -- 549
							requestId = 0 -- 550
							if stopToken.stopped then -- 550
								finishReject("request cancelled") -- 552
								return -- 553
							end -- 553
							if data ~= nil then -- 553
								finishResolve(data) -- 556
							else -- 556
								finishReject("failed to get http response") -- 558
							end -- 558
						end -- 549
					) -- 549
					if requestId == 0 then -- 549
						finishReject("failed to schedule http request") -- 562
					elseif stopToken.stopped then -- 562
						HttpClient:cancel(requestId) -- 564
						requestId = 0 -- 565
						finishReject("request cancelled") -- 566
					end -- 566
				else -- 566
					finishReject(err) -- 569
				end -- 569
			end)) -- 528
		end -- 501
	) -- 501
end -- 483
function ____exports.createSSEJSONParser(opts) -- 579
	local buffer = "" -- 584
	local eventDataLines = {} -- 585
	local function flushEventIfAny() -- 587
		if #eventDataLines == 0 then -- 587
			return -- 588
		end -- 588
		local dataPayload = table.concat(eventDataLines, "\n") -- 590
		eventDataLines = {} -- 591
		if dataPayload == "[DONE]" then -- 591
			local ____opt_1 = opts.onDone -- 591
			if ____opt_1 ~= nil then -- 591
				____opt_1(dataPayload) -- 594
			end -- 594
			return -- 595
		end -- 595
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 598
		if err == nil then -- 598
			opts.onJSON(obj, dataPayload) -- 600
		else -- 600
			local ____opt_3 = opts.onError -- 600
			if ____opt_3 ~= nil then -- 600
				____opt_3(err, {raw = dataPayload}) -- 602
			end -- 602
		end -- 602
	end -- 587
	local function feed(chunk) -- 606
		buffer = buffer .. chunk -- 607
		while true do -- 607
			do -- 607
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 610
				if nl < 0 then -- 610
					break -- 611
				end -- 611
				local line = __TS__StringSlice(buffer, 0, nl) -- 613
				buffer = __TS__StringSlice(buffer, nl + 1) -- 614
				if __TS__StringEndsWith(line, "\r") then -- 614
					line = string.sub(line, 1, -2) -- 616
				end -- 616
				if line == "" then -- 616
					flushEventIfAny() -- 619
					goto __continue158 -- 620
				end -- 620
				if __TS__StringStartsWith(line, ":") then -- 620
					goto __continue158 -- 624
				end -- 624
				if __TS__StringStartsWith(line, "data:") then -- 624
					local v = string.sub(line, 6) -- 627
					if __TS__StringStartsWith(v, " ") then -- 627
						v = string.sub(v, 2) -- 628
					end -- 628
					eventDataLines[#eventDataLines + 1] = v -- 629
					goto __continue158 -- 630
				end -- 630
			end -- 630
			::__continue158:: -- 630
		end -- 630
	end -- 606
	local function ____end() -- 635
		if #buffer > 0 then -- 635
			local line = buffer -- 637
			buffer = "" -- 638
			if __TS__StringEndsWith(line, "\r") then -- 638
				line = string.sub(line, 1, -2) -- 639
			end -- 639
			if __TS__StringStartsWith(line, "data:") then -- 639
				local v = string.sub(line, 6) -- 642
				if __TS__StringStartsWith(v, " ") then -- 642
					v = string.sub(v, 2) -- 643
				end -- 643
				eventDataLines[#eventDataLines + 1] = v -- 644
			end -- 644
		end -- 644
		flushEventIfAny() -- 647
	end -- 635
	return {feed = feed, ["end"] = ____end} -- 650
end -- 579
local function normalizeContextWindow(value) -- 741
	if type(value) == "number" then -- 741
		return math.max( -- 743
			4000, -- 743
			math.floor(value) -- 743
		) -- 743
	end -- 743
	return 64000 -- 745
end -- 741
local function normalizeSupportsFunctionCalling(value) -- 748
	return value == nil or value == nil or value ~= 0 -- 749
end -- 748
function ____exports.getActiveLLMConfig() -- 752
	local rows = DB:query("select * from LLMConfig", true) -- 753
	local records = {} -- 754
	if rows and #rows > 1 then -- 754
		do -- 754
			local i = 1 -- 756
			while i < #rows do -- 756
				local record = {} -- 757
				do -- 757
					local c = 0 -- 758
					while c < #rows[i + 1] do -- 758
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 759
						c = c + 1 -- 758
					end -- 758
				end -- 758
				records[#records + 1] = record -- 761
				i = i + 1 -- 756
			end -- 756
		end -- 756
	end -- 756
	local config = __TS__ArrayFind( -- 764
		records, -- 764
		function(____, r) return r.active ~= 0 end -- 764
	) -- 764
	if not config then -- 764
		return {success = false, message = "no active LLM config"} -- 766
	end -- 766
	local url = config.url -- 766
	local model = config.model -- 766
	local api_key = config.api_key -- 766
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 766
		return {success = false, message = "got invalude LLM config"} -- 770
	end -- 770
	return { -- 772
		success = true, -- 773
		config = { -- 774
			url = url, -- 775
			model = model, -- 776
			apiKey = api_key, -- 777
			contextWindow = normalizeContextWindow(config.context_window), -- 778
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 779
		} -- 779
	} -- 779
end -- 752
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 784
	local callEvent -- 790
	if event.id ~= nil then -- 790
		local id = event.id -- 792
		callEvent = { -- 793
			id = nil, -- 794
			onData = function(data) -- 795
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 796
				return event.stopToken.stopped -- 797
			end, -- 795
			onCancel = function(reason) -- 799
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 800
			end, -- 799
			onDone = function() -- 802
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 803
			end -- 802
		} -- 802
	else -- 802
		callEvent = event -- 807
	end -- 807
	local ____callEvent_5 = callEvent -- 809
	local onData = ____callEvent_5.onData -- 809
	local onDone = ____callEvent_5.onDone -- 809
	local ____callEvent_6 = callEvent -- 810
	local onCancel = ____callEvent_6.onCancel -- 810
	local config = llmConfig or (function() -- 811
		local configRes = ____exports.getActiveLLMConfig() -- 812
		if not configRes.success then -- 812
			if onCancel then -- 812
				onCancel(configRes.message) -- 814
			end -- 814
			return nil -- 815
		end -- 815
		return configRes.config -- 817
	end)() -- 811
	if not config then -- 811
		return {success = false, message = "no active LLM config"} -- 820
	end -- 820
	local url = config.url -- 820
	local model = config.model -- 820
	local apiKey = config.apiKey -- 820
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 823
	if fitted.trimmed then -- 823
		____exports.Log( -- 825
			"Warn", -- 825
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 825
		) -- 825
	end -- 825
	local stopLLM = false -- 827
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 828
		local result = onData(obj) -- 830
		if result then -- 830
			stopLLM = result -- 831
		end -- 831
	end}); -- 829
	(function() -- 834
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 834
			local ____try = __TS__AsyncAwaiter(function() -- 834
				local ____array_8 = __TS__SparseArrayNew( -- 834
					fitted.messages, -- 836
					url, -- 836
					apiKey, -- 836
					model, -- 836
					options, -- 836
					true, -- 836
					function(data) -- 836
						if stopLLM then -- 836
							if onCancel then -- 836
								onCancel("LLM Stopped") -- 839
								onCancel = nil -- 840
							end -- 840
							return true -- 842
						end -- 842
						parser.feed(data) -- 844
						return false -- 845
					end -- 836
				) -- 836
				local ____temp_7 -- 846
				if event.stopToken ~= nil then -- 846
					____temp_7 = event.stopToken -- 846
				else -- 846
					____temp_7 = nil -- 846
				end -- 846
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 846
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 836
				parser["end"]() -- 847
				if onDone then -- 847
					onDone(result) -- 849
				end -- 849
			end) -- 849
			__TS__Await(____try.catch( -- 835
				____try, -- 835
				function(____, e) -- 835
					stopLLM = true -- 852
					if onCancel then -- 852
						onCancel(tostring(e)) -- 854
						onCancel = nil -- 855
					end -- 855
				end -- 855
			)) -- 855
		end) -- 855
	end)() -- 834
	return {success = true} -- 859
end -- 784
local function mergeStreamToolCall(target, delta) -- 862
	if type(delta.id) == "string" and delta.id ~= "" then -- 862
		target.id = delta.id -- 864
	end -- 864
	if type(delta.type) == "string" and delta.type ~= "" then -- 864
		target.type = delta.type -- 867
	end -- 867
	if delta["function"] then -- 867
		if target["function"] == nil then -- 867
			target["function"] = {} -- 870
		end -- 870
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 870
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 872
		end -- 872
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 872
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 875
		end -- 875
	end -- 875
end -- 862
local function mergeStreamChoice(acc, choice) -- 880
	local delta = choice.delta or ({}) -- 881
	local message = acc.message -- 882
	if type(delta.role) == "string" and delta.role ~= "" then -- 882
		message.role = delta.role -- 884
	end -- 884
	if type(delta.content) == "string" and delta.content ~= "" then -- 884
		message.content = (message.content or "") .. delta.content -- 887
	end -- 887
	if type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" then -- 887
		message.reasoning_content = (message.reasoning_content or "") .. delta.reasoning_content -- 890
	end -- 890
	if delta.tool_calls and #delta.tool_calls > 0 then -- 890
		if message.tool_calls == nil then -- 890
			message.tool_calls = {} -- 893
		end -- 893
		do -- 893
			local i = 0 -- 894
			while i < #delta.tool_calls do -- 894
				local item = delta.tool_calls[i + 1] -- 895
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 896
				local ____message_tool_calls_9, ____temp_10 = message.tool_calls, index + 1 -- 896
				if ____message_tool_calls_9[____temp_10] == nil then -- 896
					____message_tool_calls_9[____temp_10] = {} -- 899
				end -- 899
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 900
				i = i + 1 -- 894
			end -- 894
		end -- 894
	end -- 894
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 894
		acc.finish_reason = choice.finish_reason -- 904
	end -- 904
end -- 880
local function buildStreamResponse(states, model, id, created, object, providerError) -- 908
	local indexes = __TS__ArraySort( -- 916
		__TS__ArrayFilter( -- 916
			__TS__ArrayMap( -- 916
				__TS__ObjectKeys(states), -- 916
				function(____, key) return __TS__Number(key) end -- 917
			), -- 917
			function(____, index) return __TS__NumberIsFinite(index) end -- 918
		), -- 918
		function(____, a, b) return a - b end -- 919
	) -- 919
	return { -- 920
		id = id, -- 921
		created = created, -- 922
		object = object, -- 923
		model = model, -- 924
		choices = __TS__ArrayMap( -- 925
			indexes, -- 925
			function(____, index) -- 925
				local state = states[index] -- 926
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 927
			end -- 925
		), -- 925
		error = providerError -- 938
	} -- 938
end -- 908
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk) -- 942
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 942
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 949
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 950
		local resolvedConfig = config or (function() -- 953
			local configRes = ____exports.getActiveLLMConfig() -- 954
			if not configRes.success then -- 954
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 956
				return nil -- 957
			end -- 957
			return configRes.config -- 959
		end)() -- 953
		if not resolvedConfig then -- 953
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 953
		end -- 953
		local url = resolvedConfig.url -- 953
		local model = resolvedConfig.model -- 953
		local apiKey = resolvedConfig.apiKey -- 953
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 965
		____exports.Log( -- 966
			"Info", -- 966
			((((("[Agent.Utils] callLLMStreamAggregated request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 966
		) -- 966
		if stopToken and stopToken.stopped then -- 966
			local reason = stopToken.reason or "request cancelled" -- 968
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 969
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 969
		end -- 969
		local ____try = __TS__AsyncAwaiter(function() -- 969
			local states = {} -- 973
			local responseId = nil -- 974
			local responseCreated = nil -- 975
			local responseObject = nil -- 976
			local providerError -- 977
			local parser = ____exports.createSSEJSONParser({ -- 978
				onJSON = function(obj, raw) -- 979
					if not obj or type(obj) ~= "table" then -- 979
						return -- 981
					end -- 981
					local chunk = obj -- 983
					if chunk.error then -- 983
						providerError = chunk.error -- 985
						____exports.Log( -- 986
							"Warn", -- 986
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 986
						) -- 986
						return -- 987
					end -- 987
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 989
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 990
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 991
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 992
					do -- 992
						local i = 0 -- 993
						while i < #choices do -- 993
							local choice = choices[i + 1] -- 994
							local index = type(choice.index) == "number" and choice.index or i -- 995
							if states[index] == nil then -- 995
								states[index] = {index = index, message = {role = "assistant"}} -- 996
							end -- 996
							mergeStreamChoice(states[index], choice) -- 1000
							i = i + 1 -- 993
						end -- 993
					end -- 993
					if onChunk ~= nil then -- 993
						onChunk( -- 1002
							buildStreamResponse( -- 1003
								states, -- 1003
								model, -- 1003
								responseId, -- 1003
								responseCreated, -- 1003
								responseObject, -- 1003
								providerError -- 1003
							), -- 1003
							{ -- 1004
								id = chunk.id or "", -- 1005
								created = chunk.created or 0, -- 1006
								object = chunk.object or "", -- 1007
								model = chunk.model or model, -- 1008
								choices = choices -- 1009
							} -- 1009
						) -- 1009
					end -- 1009
				end, -- 979
				onError = function(err, context) -- 1013
					____exports.Log( -- 1014
						"Warn", -- 1014
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1014
					) -- 1014
				end -- 1013
			}) -- 1013
			__TS__Await(postLLM( -- 1017
				fitted.messages, -- 1017
				url, -- 1017
				apiKey, -- 1017
				model, -- 1017
				options, -- 1017
				true, -- 1017
				function(data) -- 1017
					if stopToken and stopToken.stopped then -- 1017
						return true -- 1018
					end -- 1018
					parser.feed(data) -- 1019
					return false -- 1020
				end, -- 1017
				stopToken -- 1021
			)) -- 1021
			parser["end"]() -- 1022
			local response = buildStreamResponse( -- 1023
				states, -- 1023
				model, -- 1023
				responseId, -- 1023
				responseCreated, -- 1023
				responseObject, -- 1023
				providerError -- 1023
			) -- 1023
			local choiceCount = response.choices and #response.choices or 0 -- 1024
			____exports.Log( -- 1025
				"Info", -- 1025
				"[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount) -- 1025
			) -- 1025
			if not response.choices or #response.choices == 0 then -- 1025
				local providerMessage = providerError and providerError.message or "" -- 1027
				local providerType = providerError and providerError.type or "" -- 1028
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1029
				local details = table.concat( -- 1032
					__TS__ArrayFilter( -- 1032
						{providerType, providerCode}, -- 1032
						function(____, part) return part ~= "" end -- 1032
					), -- 1032
					"/" -- 1032
				) -- 1032
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices" -- 1033
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated empty choices") -- 1036
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1036
			end -- 1036
			return ____awaiter_resolve(nil, {success = true, response = response}) -- 1036
		end) -- 1036
		__TS__Await(____try.catch( -- 972
			____try, -- 972
			function(____, e) -- 972
				if stopToken and stopToken.stopped then -- 972
					local reason = stopToken.reason or "request cancelled" -- 1048
					____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1049
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1049
				end -- 1049
				____exports.Log( -- 1052
					"Error", -- 1052
					"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1052
				) -- 1052
				return ____awaiter_resolve( -- 1052
					nil, -- 1052
					{ -- 1053
						success = false, -- 1053
						message = tostring(e) -- 1053
					} -- 1053
				) -- 1053
			end -- 1053
		)) -- 1053
	end) -- 1053
end -- 942
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1057
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1057
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1063
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1064
		local resolvedConfig = config or (function() -- 1067
			local configRes = ____exports.getActiveLLMConfig() -- 1068
			if not configRes.success then -- 1068
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1070
				return nil -- 1071
			end -- 1071
			return configRes.config -- 1073
		end)() -- 1067
		if not resolvedConfig then -- 1067
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1067
		end -- 1067
		local url = resolvedConfig.url -- 1067
		local model = resolvedConfig.model -- 1067
		local apiKey = resolvedConfig.apiKey -- 1067
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1079
		____exports.Log( -- 1080
			"Info", -- 1080
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1080
		) -- 1080
		if stopToken and stopToken.stopped then -- 1080
			local reason = stopToken.reason or "request cancelled" -- 1082
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1083
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1083
		end -- 1083
		local ____try = __TS__AsyncAwaiter(function() -- 1083
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1087
				fitted.messages, -- 1087
				url, -- 1087
				apiKey, -- 1087
				model, -- 1087
				options, -- 1087
				false, -- 1087
				nil, -- 1087
				stopToken -- 1087
			))) -- 1087
			____exports.Log( -- 1088
				"Info", -- 1088
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 1088
			) -- 1088
			local response, err = ____exports.safeJsonDecode(raw) -- 1089
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1089
				local rawPreview = previewText(raw) -- 1091
				____exports.Log( -- 1092
					"Error", -- 1092
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1092
				) -- 1092
				return ____awaiter_resolve( -- 1092
					nil, -- 1092
					{ -- 1093
						success = false, -- 1094
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1095
						raw = raw -- 1096
					} -- 1096
				) -- 1096
			end -- 1096
			local responseObj = response -- 1099
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1100
			____exports.Log( -- 1101
				"Info", -- 1101
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1101
			) -- 1101
			if not responseObj.choices or #responseObj.choices == 0 then -- 1101
				local providerError = responseObj.error -- 1103
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1104
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1107
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1110
				local details = table.concat( -- 1113
					__TS__ArrayFilter( -- 1113
						{providerType, providerCode}, -- 1113
						function(____, part) return part ~= "" end -- 1113
					), -- 1113
					"/" -- 1113
				) -- 1113
				local rawPreview = previewText(raw, 400) -- 1114
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1115
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1118
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 1118
			end -- 1118
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 1118
		end) -- 1118
		__TS__Await(____try.catch( -- 1086
			____try, -- 1086
			function(____, e) -- 1086
				if stopToken and stopToken.stopped then -- 1086
					local reason = stopToken.reason or "request cancelled" -- 1131
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1132
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1132
				end -- 1132
				____exports.Log( -- 1135
					"Error", -- 1135
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1135
				) -- 1135
				return ____awaiter_resolve( -- 1135
					nil, -- 1135
					{ -- 1136
						success = false, -- 1136
						message = tostring(e) -- 1136
					} -- 1136
				) -- 1136
			end -- 1136
		)) -- 1136
	end) -- 1136
end -- 1057
return ____exports -- 1057