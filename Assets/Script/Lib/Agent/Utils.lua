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
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
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
		return {value, err} -- 126
	end -- 126
	return { -- 128
		sanitizeJSONValue(value), -- 128
		err -- 128
	} -- 128
end -- 123
local function utf8TakeHead(text, maxChars) -- 131
	if maxChars <= 0 or text == "" then -- 131
		return "" -- 132
	end -- 132
	local nextPos = utf8.offset(text, maxChars + 1) -- 133
	if nextPos == nil then -- 133
		return text -- 134
	end -- 134
	return string.sub(text, 1, nextPos - 1) -- 135
end -- 131
local function utf8TakeTail(text, maxChars) -- 138
	if maxChars <= 0 or text == "" then -- 138
		return "" -- 139
	end -- 139
	local charLen = utf8.len(text) -- 140
	if charLen == nil or charLen <= maxChars then -- 140
		return text -- 141
	end -- 141
	local startChar = math.max(1, charLen - maxChars + 1) -- 142
	local startPos = utf8.offset(text, startChar) -- 143
	if startPos == nil then -- 143
		return text -- 144
	end -- 144
	return string.sub(text, startPos) -- 145
end -- 138
function ____exports.estimateTextTokens(text) -- 148
	if not text then -- 148
		return 0 -- 149
	end -- 149
	local charLen = utf8.len(text) -- 150
	if not charLen or charLen <= 0 then -- 150
		return 0 -- 151
	end -- 151
	local otherChars = #text - charLen -- 152
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 153
	return math.max(1, tokens) -- 154
end -- 148
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
	local contextWindow = math.max(4000, config.contextWindow) -- 189
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
				goto __continue68 -- 278
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
				goto __continue68 -- 284
			end -- 284
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 284
				depth = depth - 1 -- 287
				if depth == 0 then -- 287
					return {success = true, closeStart = lt} -- 288
				end -- 288
				pos = lt + #sameCloseToken -- 289
				goto __continue68 -- 290
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
				goto __continue68 -- 301
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
		::__continue68:: -- 305
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
						goto __continue89 -- 332
					end -- 332
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 333
				end -- 333
				::__continue89:: -- 333
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
				goto __continue94 -- 365
			end -- 365
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 367
			if not closeRes.success then -- 367
				return closeRes -- 368
			end -- 368
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 369
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 370
			pos = closeRes.closeStart + #closeToken -- 371
		end -- 371
		::__continue94:: -- 371
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
	local cloned = __TS__ArrayMap( -- 401
		messages, -- 401
		function(____, message) return __TS__ObjectAssign({}, message) end -- 401
	) -- 401
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 402
	local originalTokens = estimateMessagesTokens(cloned) -- 403
	if originalTokens <= budgetTokens then -- 403
		return { -- 405
			messages = cloned, -- 406
			trimmed = false, -- 407
			originalTokens = originalTokens, -- 408
			fittedTokens = originalTokens, -- 409
			budgetTokens = budgetTokens -- 410
		} -- 410
	end -- 410
	local function roleOverhead(message) -- 414
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 414
	end -- 414
	local fixedOverhead = 0 -- 415
	local contentIndexes = {} -- 416
	do -- 416
		local i = 0 -- 417
		while i < #cloned do -- 417
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 418
			contentIndexes[#contentIndexes + 1] = i -- 419
			i = i + 1 -- 417
		end -- 417
	end -- 417
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 421
	if #contentIndexes == 1 then -- 421
		local idx = contentIndexes[1] -- 423
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 424
		local fittedTokens = estimateMessagesTokens(cloned) -- 425
		return { -- 426
			messages = cloned, -- 427
			trimmed = true, -- 428
			originalTokens = originalTokens, -- 429
			fittedTokens = fittedTokens, -- 430
			budgetTokens = budgetTokens -- 431
		} -- 431
	end -- 431
	local nonSystemIndexes = {} -- 435
	local systemIndexes = {} -- 436
	do -- 436
		local i = 0 -- 437
		while i < #cloned do -- 437
			if cloned[i + 1].role == "system" then -- 437
				systemIndexes[#systemIndexes + 1] = i -- 438
			else -- 438
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 439
			end -- 439
			i = i + 1 -- 437
		end -- 437
	end -- 437
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 437
	__TS__SparseArrayPush( -- 437
		____array_0, -- 437
		table.unpack(systemIndexes) -- 441
	) -- 441
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 441
	local remainingContentBudget = contentBudget -- 442
	do -- 442
		local i = #priorityIndexes - 1 -- 443
		while i >= 0 do -- 443
			local idx = priorityIndexes[i + 1] -- 444
			local message = cloned[idx + 1] -- 445
			local minBudget = message.role == "system" and 96 or 192 -- 446
			local target = math.max( -- 447
				minBudget, -- 447
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 447
			) -- 447
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 448
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 449
			remainingContentBudget = math.max(0, remainingContentBudget) -- 450
			i = i - 1 -- 443
		end -- 443
	end -- 443
	local fittedTokens = estimateMessagesTokens(cloned) -- 453
	if fittedTokens > budgetTokens then -- 453
		do -- 453
			local i = 0 -- 455
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 455
				local idx = priorityIndexes[i + 1] -- 456
				local message = cloned[idx + 1] -- 457
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 458
				local excess = fittedTokens - budgetTokens -- 459
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 460
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 461
				fittedTokens = estimateMessagesTokens(cloned) -- 462
				i = i + 1 -- 455
			end -- 455
		end -- 455
	end -- 455
	if fittedTokens > budgetTokens then -- 455
		do -- 455
			local i = 0 -- 466
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 466
				do -- 466
					local idx = priorityIndexes[i + 1] -- 467
					if cloned[idx + 1].role == "system" then -- 467
						goto __continue124 -- 468
					end -- 468
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 469
					fittedTokens = estimateMessagesTokens(cloned) -- 470
				end -- 470
				::__continue124:: -- 470
				i = i + 1 -- 466
			end -- 466
		end -- 466
	end -- 466
	return { -- 473
		messages = cloned, -- 474
		trimmed = true, -- 475
		originalTokens = originalTokens, -- 476
		fittedTokens = fittedTokens, -- 477
		budgetTokens = budgetTokens -- 478
	} -- 478
end -- 394
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 482
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 492
	if stopToken == nil then -- 492
		stopToken = {stopped = false} -- 498
	end -- 498
	return __TS__New( -- 499
		__TS__Promise, -- 499
		function(____, resolve, reject) -- 499
			local requestId = 0 -- 500
			local settled = false -- 501
			local function finishResolve(text) -- 502
				if settled then -- 502
					return -- 503
				end -- 503
				settled = true -- 504
				resolve(nil, text) -- 505
			end -- 502
			local function finishReject(err) -- 507
				if settled then -- 507
					return -- 508
				end -- 508
				settled = true -- 509
				reject(nil, err) -- 510
			end -- 507
			Director.systemScheduler:schedule(function() -- 512
				if not settled then -- 512
					if stopToken.stopped then -- 512
						if requestId ~= 0 then -- 512
							HttpClient:cancel(requestId) -- 516
							requestId = 0 -- 517
						end -- 517
						finishReject("request cancelled") -- 519
						return true -- 520
					end -- 520
					return false -- 522
				end -- 522
				return true -- 524
			end) -- 512
			Director.systemScheduler:schedule(once(function() -- 526
				emit( -- 527
					"LLM_IN", -- 527
					table.concat( -- 527
						__TS__ArrayMap( -- 527
							messages, -- 527
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 527
						), -- 527
						"\n" -- 527
					) -- 527
				) -- 527
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 528
				if jsonStr ~= nil then -- 528
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 530
					requestId = receiver and HttpClient:post( -- 535
						url, -- 536
						headers, -- 536
						jsonStr, -- 536
						LLM_TIMEOUT, -- 536
						function(data) -- 536
							if stopToken.stopped then -- 536
								return true -- 537
							end -- 537
							return receiver(data) -- 538
						end, -- 536
						function(data) -- 539
							requestId = 0 -- 540
							if data ~= nil then -- 540
								finishResolve(data) -- 542
							else -- 542
								finishReject("failed to get http response") -- 544
							end -- 544
						end -- 539
					) or HttpClient:post( -- 539
						url, -- 547
						headers, -- 547
						jsonStr, -- 547
						LLM_TIMEOUT, -- 547
						function(data) -- 547
							requestId = 0 -- 548
							if stopToken.stopped then -- 548
								finishReject("request cancelled") -- 550
								return -- 551
							end -- 551
							if data ~= nil then -- 551
								finishResolve(data) -- 554
							else -- 554
								finishReject("failed to get http response") -- 556
							end -- 556
						end -- 547
					) -- 547
					if requestId == 0 then -- 547
						finishReject("failed to schedule http request") -- 560
					elseif stopToken.stopped then -- 560
						HttpClient:cancel(requestId) -- 562
						requestId = 0 -- 563
						finishReject("request cancelled") -- 564
					end -- 564
				else -- 564
					finishReject(err) -- 567
				end -- 567
			end)) -- 526
		end -- 499
	) -- 499
end -- 482
function ____exports.createSSEJSONParser(opts) -- 577
	local buffer = "" -- 582
	local eventDataLines = {} -- 583
	local function flushEventIfAny() -- 585
		if #eventDataLines == 0 then -- 585
			return -- 586
		end -- 586
		local dataPayload = table.concat(eventDataLines, "\n") -- 588
		eventDataLines = {} -- 589
		if dataPayload == "[DONE]" then -- 589
			local ____opt_1 = opts.onDone -- 589
			if ____opt_1 ~= nil then -- 589
				____opt_1(dataPayload) -- 592
			end -- 592
			return -- 593
		end -- 593
		local obj, err = table.unpack( -- 596
			____exports.safeJsonDecode(dataPayload), -- 596
			1, -- 596
			2 -- 596
		) -- 596
		if err == nil then -- 596
			opts.onJSON(obj, dataPayload) -- 598
		else -- 598
			local ____opt_3 = opts.onError -- 598
			if ____opt_3 ~= nil then -- 598
				____opt_3(err, {raw = dataPayload}) -- 600
			end -- 600
		end -- 600
	end -- 585
	local function feed(chunk) -- 604
		buffer = buffer .. chunk -- 605
		while true do -- 605
			do -- 605
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 608
				if nl < 0 then -- 608
					break -- 609
				end -- 609
				local line = __TS__StringSlice(buffer, 0, nl) -- 611
				buffer = __TS__StringSlice(buffer, nl + 1) -- 612
				if __TS__StringEndsWith(line, "\r") then -- 612
					line = string.sub(line, 1, -2) -- 614
				end -- 614
				if line == "" then -- 614
					flushEventIfAny() -- 617
					goto __continue158 -- 618
				end -- 618
				if __TS__StringStartsWith(line, ":") then -- 618
					goto __continue158 -- 622
				end -- 622
				if __TS__StringStartsWith(line, "data:") then -- 622
					local v = string.sub(line, 6) -- 625
					if __TS__StringStartsWith(v, " ") then -- 625
						v = string.sub(v, 2) -- 626
					end -- 626
					eventDataLines[#eventDataLines + 1] = v -- 627
					goto __continue158 -- 628
				end -- 628
			end -- 628
			::__continue158:: -- 628
		end -- 628
	end -- 604
	local function ____end() -- 633
		if #buffer > 0 then -- 633
			local line = buffer -- 635
			buffer = "" -- 636
			if __TS__StringEndsWith(line, "\r") then -- 636
				line = string.sub(line, 1, -2) -- 637
			end -- 637
			if __TS__StringStartsWith(line, "data:") then -- 637
				local v = string.sub(line, 6) -- 640
				if __TS__StringStartsWith(v, " ") then -- 640
					v = string.sub(v, 2) -- 641
				end -- 641
				eventDataLines[#eventDataLines + 1] = v -- 642
			end -- 642
		end -- 642
		flushEventIfAny() -- 645
	end -- 633
	return {feed = feed, ["end"] = ____end} -- 648
end -- 577
local function normalizeContextWindow(value) -- 717
	if type(value) == "number" then -- 717
		return math.max( -- 719
			4000, -- 719
			math.floor(value) -- 719
		) -- 719
	end -- 719
	return 64000 -- 721
end -- 717
local function normalizeSupportsFunctionCalling(value) -- 724
	return value == nil or value == nil or value ~= 0 -- 725
end -- 724
function ____exports.getActiveLLMConfig() -- 728
	local rows = DB:query("select * from LLMConfig", true) -- 729
	local records = {} -- 730
	if rows and #rows > 1 then -- 730
		do -- 730
			local i = 1 -- 732
			while i < #rows do -- 732
				local record = {} -- 733
				do -- 733
					local c = 0 -- 734
					while c < #rows[i + 1] do -- 734
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 735
						c = c + 1 -- 734
					end -- 734
				end -- 734
				records[#records + 1] = record -- 737
				i = i + 1 -- 732
			end -- 732
		end -- 732
	end -- 732
	local config = __TS__ArrayFind( -- 740
		records, -- 740
		function(____, r) return r.active ~= 0 end -- 740
	) -- 740
	if not config then -- 740
		return {success = false, message = "no active LLM config"} -- 742
	end -- 742
	local url = config.url -- 742
	local model = config.model -- 742
	local api_key = config.api_key -- 742
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 742
		return {success = false, message = "got invalude LLM config"} -- 746
	end -- 746
	return { -- 748
		success = true, -- 749
		config = { -- 750
			url = url, -- 751
			model = model, -- 752
			apiKey = api_key, -- 753
			contextWindow = normalizeContextWindow(config.context_window), -- 754
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 755
		} -- 755
	} -- 755
end -- 728
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 760
	local callEvent -- 766
	if event.id ~= nil then -- 766
		local id = event.id -- 768
		callEvent = { -- 769
			id = nil, -- 770
			onData = function(data) -- 771
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 772
				return event.stopToken.stopped -- 773
			end, -- 771
			onCancel = function(reason) -- 775
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 776
			end, -- 775
			onDone = function() -- 778
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 779
			end -- 778
		} -- 778
	else -- 778
		callEvent = event -- 783
	end -- 783
	local ____callEvent_5 = callEvent -- 785
	local onData = ____callEvent_5.onData -- 785
	local onDone = ____callEvent_5.onDone -- 785
	local ____callEvent_6 = callEvent -- 786
	local onCancel = ____callEvent_6.onCancel -- 786
	local config = llmConfig or (function() -- 787
		local configRes = ____exports.getActiveLLMConfig() -- 788
		if not configRes.success then -- 788
			if onCancel then -- 788
				onCancel(configRes.message) -- 790
			end -- 790
			return nil -- 791
		end -- 791
		return configRes.config -- 793
	end)() -- 787
	if not config then -- 787
		return {success = false, message = "no active LLM config"} -- 796
	end -- 796
	local url = config.url -- 796
	local model = config.model -- 796
	local apiKey = config.apiKey -- 796
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 799
	if fitted.trimmed then -- 799
		____exports.Log( -- 801
			"Warn", -- 801
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 801
		) -- 801
	end -- 801
	local stopLLM = false -- 803
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 804
		local result = onData(obj) -- 806
		if result then -- 806
			stopLLM = result -- 807
		end -- 807
	end}); -- 805
	(function() -- 810
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 810
			local ____try = __TS__AsyncAwaiter(function() -- 810
				local ____array_8 = __TS__SparseArrayNew( -- 810
					fitted.messages, -- 812
					url, -- 812
					apiKey, -- 812
					model, -- 812
					options, -- 812
					true, -- 812
					function(data) -- 812
						if stopLLM then -- 812
							if onCancel then -- 812
								onCancel("LLM Stopped") -- 815
								onCancel = nil -- 816
							end -- 816
							return true -- 818
						end -- 818
						parser.feed(data) -- 820
						return false -- 821
					end -- 812
				) -- 812
				local ____temp_7 -- 822
				if event.stopToken ~= nil then -- 822
					____temp_7 = event.stopToken -- 822
				else -- 822
					____temp_7 = nil -- 822
				end -- 822
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 822
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 812
				parser["end"]() -- 823
				if onDone then -- 823
					onDone(result) -- 825
				end -- 825
			end) -- 825
			__TS__Await(____try.catch( -- 811
				____try, -- 811
				function(____, e) -- 811
					stopLLM = true -- 828
					if onCancel then -- 828
						onCancel(tostring(e)) -- 830
						onCancel = nil -- 831
					end -- 831
				end -- 831
			)) -- 831
		end) -- 831
	end)() -- 810
	return {success = true} -- 835
end -- 760
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 838
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 838
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 844
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 845
		local resolvedConfig = config or (function() -- 848
			local configRes = ____exports.getActiveLLMConfig() -- 849
			if not configRes.success then -- 849
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 851
				return nil -- 852
			end -- 852
			return configRes.config -- 854
		end)() -- 848
		if not resolvedConfig then -- 848
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 848
		end -- 848
		local url = resolvedConfig.url -- 848
		local model = resolvedConfig.model -- 848
		local apiKey = resolvedConfig.apiKey -- 848
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 860
		____exports.Log( -- 861
			"Info", -- 861
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 861
		) -- 861
		if stopToken and stopToken.stopped then -- 861
			local reason = stopToken.reason or "request cancelled" -- 863
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 864
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 864
		end -- 864
		local ____try = __TS__AsyncAwaiter(function() -- 864
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 868
				fitted.messages, -- 868
				url, -- 868
				apiKey, -- 868
				model, -- 868
				options, -- 868
				false, -- 868
				nil, -- 868
				stopToken -- 868
			))) -- 868
			____exports.Log( -- 869
				"Info", -- 869
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 869
			) -- 869
			local response, err = table.unpack( -- 870
				____exports.safeJsonDecode(raw), -- 870
				1, -- 870
				2 -- 870
			) -- 870
			if err ~= nil or response == nil or type(response) ~= "table" then -- 870
				local rawPreview = previewText(raw) -- 872
				____exports.Log( -- 873
					"Error", -- 873
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 873
				) -- 873
				return ____awaiter_resolve( -- 873
					nil, -- 873
					{ -- 874
						success = false, -- 875
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 876
						raw = raw -- 877
					} -- 877
				) -- 877
			end -- 877
			local responseObj = response -- 880
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 881
			____exports.Log( -- 882
				"Info", -- 882
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 882
			) -- 882
			if not responseObj.choices or #responseObj.choices == 0 then -- 882
				local providerError = responseObj.error -- 884
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 885
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 888
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 891
				local details = table.concat( -- 894
					__TS__ArrayFilter( -- 894
						{providerType, providerCode}, -- 894
						function(____, part) return part ~= "" end -- 894
					), -- 894
					"/" -- 894
				) -- 894
				local rawPreview = previewText(raw, 400) -- 895
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 896
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 899
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 899
			end -- 899
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 899
		end) -- 899
		__TS__Await(____try.catch( -- 867
			____try, -- 867
			function(____, e) -- 867
				if stopToken and stopToken.stopped then -- 867
					local reason = stopToken.reason or "request cancelled" -- 912
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 913
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 913
				end -- 913
				____exports.Log( -- 916
					"Error", -- 916
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 916
				) -- 916
				return ____awaiter_resolve( -- 916
					nil, -- 916
					{ -- 917
						success = false, -- 917
						message = tostring(e) -- 917
					} -- 917
				) -- 917
			end -- 917
		)) -- 917
	end) -- 917
end -- 838
return ____exports -- 838