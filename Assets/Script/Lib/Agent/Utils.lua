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
local LLM_STREAM_TIMEOUT = 600 -- 10
____exports.Log = function(____type, msg) -- 12
	if LOG_LEVEL < 1 then -- 12
		return -- 13
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then -- 13
		return -- 14
	elseif LOG_LEVEL < 3 and ____type == "Info" then -- 14
		return -- 15
	end -- 15
	DoraLog(____type, msg) -- 16
end -- 12
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 43
local TOOL_CALL_ID_COUNTER = 0 -- 44
local function toBase36(value) -- 46
	if value <= 0 then -- 46
		return "0" -- 47
	end -- 47
	local remaining = math.floor(value) -- 48
	local out = "" -- 49
	while remaining > 0 do -- 49
		local digit = remaining % 36 -- 51
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 52
		remaining = math.floor(remaining / 36) -- 53
	end -- 53
	return out -- 55
end -- 46
function ____exports.createLocalToolCallId() -- 58
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 59
	local timePart = toBase36(os.time()) -- 60
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 61
	return ("tc" .. timePart) .. counterPart -- 62
end -- 58
local function previewText(text, maxLen) -- 70
	if maxLen == nil then -- 70
		maxLen = 200 -- 70
	end -- 70
	if not text then -- 70
		return "" -- 71
	end -- 71
	local compact = __TS__StringReplace( -- 72
		__TS__StringReplace(text, "\r", "\\r"), -- 72
		"\n", -- 72
		"\\n" -- 72
	) -- 72
	if #compact <= maxLen then -- 72
		return compact -- 73
	end -- 73
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 74
end -- 70
function ____exports.sanitizeUTF8(text) -- 77
	if not text then -- 77
		return "" -- 78
	end -- 78
	local remaining = text -- 79
	local output = "" -- 80
	while remaining ~= "" do -- 80
		local len, invalidPos = utf8.len(remaining) -- 82
		if len ~= nil then -- 82
			output = output .. remaining -- 84
			break -- 85
		end -- 85
		local badPos = type(invalidPos) == "number" and invalidPos or 1 -- 87
		if badPos > 1 then -- 87
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1) -- 89
		end -- 89
		remaining = __TS__StringSubstring(remaining, badPos) -- 91
	end -- 91
	return output -- 93
end -- 77
local function sanitizeJSONValue(value) -- 96
	if type(value) == "string" then -- 96
		return ____exports.sanitizeUTF8(value) -- 97
	end -- 97
	if __TS__ArrayIsArray(value) then -- 97
		return __TS__ArrayMap( -- 99
			value, -- 99
			function(____, item) return sanitizeJSONValue(item) end -- 99
		) -- 99
	end -- 99
	if value and type(value) == "table" then -- 99
		local result = {} -- 102
		for key in pairs(value) do -- 103
			result[key] = sanitizeJSONValue(value[key]) -- 104
		end -- 104
		return result -- 106
	end -- 106
	return value -- 108
end -- 96
function ____exports.safeJsonEncode(value, indent, sortKeys, escapeSlash, maxDepth) -- 111
	return json.encode( -- 112
		sanitizeJSONValue(value), -- 113
		indent, -- 114
		sortKeys, -- 115
		escapeSlash, -- 116
		maxDepth -- 117
	) -- 117
end -- 111
function ____exports.safeJsonDecode(text) -- 121
	local value, err = json.decode(____exports.sanitizeUTF8(text)) -- 122
	if value == nil then -- 122
		return value, err -- 124
	end -- 124
	return sanitizeJSONValue(value), err -- 126
end -- 121
local function utf8TakeHead(text, maxChars) -- 129
	if maxChars <= 0 or text == "" then -- 129
		return "" -- 130
	end -- 130
	local nextPos = utf8.offset(text, maxChars + 1) -- 131
	if nextPos == nil then -- 131
		return text -- 132
	end -- 132
	return string.sub(text, 1, nextPos - 1) -- 133
end -- 129
local function utf8TakeTail(text, maxChars) -- 136
	if maxChars <= 0 or text == "" then -- 136
		return "" -- 137
	end -- 137
	local charLen = utf8.len(text) -- 138
	if charLen == nil or charLen <= maxChars then -- 138
		return text -- 139
	end -- 139
	local startChar = math.max(1, charLen - maxChars + 1) -- 140
	local startPos = utf8.offset(text, startChar) -- 141
	if startPos == nil then -- 141
		return text -- 142
	end -- 142
	return string.sub(text, startPos) -- 143
end -- 136
function ____exports.estimateTextTokens(text) -- 146
	if not text then -- 146
		return 0 -- 147
	end -- 147
	local charLen = utf8.len(text) -- 148
	if not charLen or charLen <= 0 then -- 148
		return 0 -- 149
	end -- 149
	local otherChars = #text - charLen -- 150
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 151
	return math.max(1, tokens) -- 152
end -- 146
local function estimateMessagesTokens(messages) -- 155
	local total = 0 -- 156
	do -- 156
		local i = 0 -- 157
		while i < #messages do -- 157
			local message = messages[i + 1] -- 158
			total = total + 8 -- 159
			total = total + ____exports.estimateTextTokens(message.role or "") -- 160
			total = total + ____exports.estimateTextTokens(message.content or "") -- 161
			total = total + ____exports.estimateTextTokens(message.name or "") -- 162
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 163
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 164
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({})) -- 165
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 166
			i = i + 1 -- 157
		end -- 157
	end -- 157
	return total -- 168
end -- 155
local function estimateOptionsTokens(options) -- 171
	local text = ____exports.safeJsonEncode(options) -- 172
	return text and ____exports.estimateTextTokens(text) or 0 -- 173
end -- 171
local function getReservedOutputTokens(options, contextWindow) -- 176
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 177
	if explicitMax > 0 then -- 177
		return math.max(256, explicitMax) -- 182
	end -- 182
	return math.max( -- 183
		1024, -- 183
		math.floor(contextWindow * 0.2) -- 183
	) -- 183
end -- 176
local function getInputTokenBudget(messages, options, config) -- 186
	local contextWindow = math.max(4000, config.contextWindow) -- 187
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 188
	local optionTokens = estimateOptionsTokens(options) -- 189
	local structuralOverhead = math.max(256, #messages * 16) -- 190
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 191
end -- 186
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 194
	if budgetTokens <= 0 or text == "" then -- 194
		return "" -- 195
	end -- 195
	local estimated = ____exports.estimateTextTokens(text) -- 196
	if estimated <= budgetTokens then -- 196
		return text -- 197
	end -- 197
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 198
	local targetChars = math.max( -- 199
		200, -- 199
		math.floor(budgetTokens * charsPerToken) -- 199
	) -- 199
	local keepHead = math.max( -- 200
		0, -- 200
		math.floor(targetChars * 0.35) -- 200
	) -- 200
	local keepTail = math.max(0, targetChars - keepHead) -- 201
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 202
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 203
	return (head .. "\n...\n") .. tail -- 204
end -- 194
local function isXMLWhitespaceChar(ch) -- 207
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" -- 208
end -- 207
local function findLineStart(value, from) -- 211
	local i = from -- 212
	while i >= 0 do -- 212
		if __TS__StringAccess(value, i) == "\n" then -- 212
			return i + 1 -- 214
		end -- 214
		i = i - 1 -- 215
	end -- 215
	return 0 -- 217
end -- 211
local function findLastLiteral(text, needle) -- 220
	if needle == "" then -- 220
		return #text -- 221
	end -- 221
	local last = -1 -- 222
	local from = 0 -- 223
	while from <= #text - #needle do -- 223
		local pos = (string.find( -- 225
			text, -- 225
			needle, -- 225
			math.max(from + 1, 1), -- 225
			true -- 225
		) or 0) - 1 -- 225
		if pos < 0 then -- 225
			break -- 226
		end -- 226
		last = pos -- 227
		from = pos + 1 -- 228
	end -- 228
	return last -- 230
end -- 220
local function unwrapXMLRawText(text) -- 233
	local trimmed = __TS__StringTrim(text) -- 234
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then -- 234
		return __TS__StringSlice(trimmed, 9, #trimmed - 3) -- 236
	end -- 236
	return text -- 238
end -- 233
local function readSimpleXMLTagName(source, openStart, openEnd) -- 241
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd)) -- 242
	if rawTag == "" then -- 242
		return { -- 244
			success = false, -- 244
			message = "invalid xml: empty tag at offset " .. tostring(openStart) -- 244
		} -- 244
	end -- 244
	local selfClosing = false -- 246
	local tagText = rawTag -- 247
	if __TS__StringEndsWith(tagText, "/") then -- 247
		selfClosing = true -- 249
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1)) -- 250
	end -- 250
	local tagName = "" -- 252
	do -- 252
		local i = 0 -- 253
		while i < #tagText do -- 253
			local ch = __TS__StringAccess(tagText, i) -- 254
			if isXMLWhitespaceChar(ch) or ch == "/" then -- 254
				break -- 255
			end -- 255
			tagName = tagName .. ch -- 256
			i = i + 1 -- 253
		end -- 253
	end -- 253
	if tagName == "" then -- 253
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"} -- 259
	end -- 259
	return {success = true, tagName = tagName, selfClosing = selfClosing} -- 261
end -- 241
local function findMatchingXMLClose(source, tagName, contentStart) -- 264
	local sameOpenPrefix = "<" .. tagName -- 265
	local sameCloseToken = ("</" .. tagName) .. ">" -- 266
	local pos = contentStart -- 267
	local depth = 1 -- 268
	while pos < #source do -- 268
		do -- 268
			local lt = (string.find( -- 270
				source, -- 270
				"<", -- 270
				math.max(pos + 1, 1), -- 270
				true -- 270
			) or 0) - 1 -- 270
			if lt < 0 then -- 270
				break -- 271
			end -- 271
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then -- 271
				local cdataEnd = (string.find( -- 273
					source, -- 273
					"]]>", -- 273
					math.max(lt + 9 + 1, 1), -- 273
					true -- 273
				) or 0) - 1 -- 273
				if cdataEnd < 0 then -- 273
					return {success = false, message = "invalid xml: unterminated CDATA"} -- 274
				end -- 274
				pos = cdataEnd + 3 -- 275
				goto __continue67 -- 276
			end -- 276
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find( -- 279
					source, -- 279
					"-->",
					math.max(lt + 4 + 1, 1), -- 279
					true -- 279
				) or 0) - 1 -- 279
				if commentEnd < 0 then -- 279
					return {success = false, message = "invalid xml: unterminated comment"} -- 280
				end -- 280
				pos = commentEnd + 3 -- 281
				goto __continue67 -- 282
			end -- 282
			if __TS__StringStartsWith(source, sameCloseToken, lt) then -- 282
				depth = depth - 1 -- 285
				if depth == 0 then -- 285
					return {success = true, closeStart = lt} -- 286
				end -- 286
				pos = lt + #sameCloseToken -- 287
				goto __continue67 -- 288
			end -- 288
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then -- 288
				local openEnd = (string.find( -- 291
					source, -- 291
					">", -- 291
					math.max(lt + 1, 1), -- 291
					true -- 291
				) or 0) - 1 -- 291
				if openEnd < 0 then -- 291
					return {success = false, message = "invalid xml: unterminated opening tag"} -- 292
				end -- 292
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd) -- 293
				if not tagInfo.success then -- 293
					return tagInfo -- 294
				end -- 294
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then -- 294
					depth = depth + 1 -- 296
				end -- 296
				pos = openEnd + 1 -- 298
				goto __continue67 -- 299
			end -- 299
			local genericEnd = (string.find( -- 301
				source, -- 301
				">", -- 301
				math.max(lt + 1, 1), -- 301
				true -- 301
			) or 0) - 1 -- 301
			if genericEnd < 0 then -- 301
				return {success = false, message = "invalid xml: unterminated nested tag"} -- 302
			end -- 302
			pos = genericEnd + 1 -- 303
		end -- 303
		::__continue67:: -- 303
	end -- 303
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"} -- 305
end -- 264
function ____exports.extractXMLFromText(text) -- 308
	local source = __TS__StringTrim(text) -- 309
	local function extractFencedBlock(fence) -- 310
		if not __TS__StringStartsWith(source, fence) then -- 310
			return nil -- 311
		end -- 311
		local firstLineEnd = (string.find( -- 312
			source, -- 312
			"\n", -- 312
			math.max(1, 1), -- 312
			true -- 312
		) or 0) - 1 -- 312
		if firstLineEnd < 0 then -- 312
			return nil -- 313
		end -- 313
		local searchPos = firstLineEnd + 1 -- 314
		local closingFencePositions = {} -- 315
		while searchPos < #source do -- 315
			local ____end = (string.find( -- 317
				source, -- 317
				"```", -- 317
				math.max(searchPos + 1, 1), -- 317
				true -- 317
			) or 0) - 1 -- 317
			if ____end < 0 then -- 317
				break -- 318
			end -- 318
			local lineStart = findLineStart(source, ____end - 1) -- 319
			local lineEnd = (string.find( -- 320
				source, -- 320
				"\n", -- 320
				math.max(____end + 1, 1), -- 320
				true -- 320
			) or 0) - 1 -- 320
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source -- 321
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then -- 321
				closingFencePositions[#closingFencePositions + 1] = ____end -- 323
			end -- 323
			searchPos = ____end + 1 -- 325
		end -- 325
		do -- 325
			local i = #closingFencePositions - 1 -- 327
			while i >= 0 do -- 327
				do -- 327
					local closingFencePos = closingFencePositions[i + 1] -- 328
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3)) -- 329
					if afterFence ~= "" then -- 329
						goto __continue88 -- 330
					end -- 330
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos)) -- 331
				end -- 331
				::__continue88:: -- 331
				i = i - 1 -- 327
			end -- 327
		end -- 327
		return nil -- 333
	end -- 310
	local xmlBlock = extractFencedBlock("```xml") -- 335
	if xmlBlock ~= nil then -- 335
		return xmlBlock -- 336
	end -- 336
	local genericBlock = extractFencedBlock("```") -- 337
	if genericBlock ~= nil then -- 337
		return genericBlock -- 338
	end -- 338
	return source -- 339
end -- 308
function ____exports.parseSimpleXMLChildren(source) -- 342
	local result = {} -- 343
	local pos = 0 -- 344
	while pos < #source do -- 344
		do -- 344
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do -- 344
				pos = pos + 1 -- 346
			end -- 346
			if pos >= #source then -- 346
				break -- 347
			end -- 347
			if __TS__StringAccess(source, pos) ~= "<" then -- 347
				return { -- 349
					success = false, -- 349
					message = "invalid xml: expected tag at offset " .. tostring(pos) -- 349
				} -- 349
			end -- 349
			if __TS__StringStartsWith(source, "</", pos) then -- 349
				return { -- 352
					success = false, -- 352
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos) -- 352
				} -- 352
			end -- 352
			local openEnd = (string.find( -- 354
				source, -- 354
				">", -- 354
				math.max(pos + 1, 1), -- 354
				true -- 354
			) or 0) - 1 -- 354
			if openEnd < 0 then -- 354
				return {success = false, message = "invalid xml: unterminated opening tag"} -- 356
			end -- 356
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd) -- 358
			if not tagInfo.success then -- 358
				return tagInfo -- 359
			end -- 359
			if tagInfo.selfClosing then -- 359
				result[tagInfo.tagName] = "" -- 361
				pos = openEnd + 1 -- 362
				goto __continue93 -- 363
			end -- 363
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1) -- 365
			if not closeRes.success then -- 365
				return closeRes -- 366
			end -- 366
			local closeToken = ("</" .. tagInfo.tagName) .. ">" -- 367
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart)) -- 368
			pos = closeRes.closeStart + #closeToken -- 369
		end -- 369
		::__continue93:: -- 369
	end -- 369
	return {success = true, obj = result} -- 371
end -- 342
function ____exports.parseXMLObjectFromText(text, rootTag) -- 374
	local xmlText = ____exports.extractXMLFromText(text) -- 375
	local rootOpen = ("<" .. rootTag) .. ">" -- 376
	local rootClose = ("</" .. rootTag) .. ">" -- 377
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1 -- 378
	local ____end = findLastLiteral(xmlText, rootClose) -- 379
	if start < 0 or ____end < start then -- 379
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"} -- 381
	end -- 381
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start)) -- 383
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose)) -- 384
	if beforeRoot ~= "" or afterRoot ~= "" then -- 384
		return {success = false, message = "invalid xml: root must be the only top-level block"} -- 386
	end -- 386
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end) -- 388
	return ____exports.parseSimpleXMLChildren(rootContent) -- 389
end -- 374
function ____exports.fitMessagesToContext(messages, options, config) -- 392
	local cloned = __TS__ArrayMap( -- 399
		messages, -- 399
		function(____, message) return __TS__ObjectAssign({}, message) end -- 399
	) -- 399
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 400
	local originalTokens = estimateMessagesTokens(cloned) -- 401
	if originalTokens <= budgetTokens then -- 401
		return { -- 403
			messages = cloned, -- 404
			trimmed = false, -- 405
			originalTokens = originalTokens, -- 406
			fittedTokens = originalTokens, -- 407
			budgetTokens = budgetTokens -- 408
		} -- 408
	end -- 408
	local function roleOverhead(message) -- 412
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 412
	end -- 412
	local fixedOverhead = 0 -- 413
	local contentIndexes = {} -- 414
	do -- 414
		local i = 0 -- 415
		while i < #cloned do -- 415
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 416
			contentIndexes[#contentIndexes + 1] = i -- 417
			i = i + 1 -- 415
		end -- 415
	end -- 415
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 419
	if #contentIndexes == 1 then -- 419
		local idx = contentIndexes[1] -- 421
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 422
		local fittedTokens = estimateMessagesTokens(cloned) -- 423
		return { -- 424
			messages = cloned, -- 425
			trimmed = true, -- 426
			originalTokens = originalTokens, -- 427
			fittedTokens = fittedTokens, -- 428
			budgetTokens = budgetTokens -- 429
		} -- 429
	end -- 429
	local nonSystemIndexes = {} -- 433
	local systemIndexes = {} -- 434
	do -- 434
		local i = 0 -- 435
		while i < #cloned do -- 435
			if cloned[i + 1].role == "system" then -- 435
				systemIndexes[#systemIndexes + 1] = i -- 436
			else -- 436
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 437
			end -- 437
			i = i + 1 -- 435
		end -- 435
	end -- 435
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 435
	__TS__SparseArrayPush( -- 435
		____array_0, -- 435
		table.unpack(systemIndexes) -- 439
	) -- 439
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 439
	local remainingContentBudget = contentBudget -- 440
	do -- 440
		local i = #priorityIndexes - 1 -- 441
		while i >= 0 do -- 441
			local idx = priorityIndexes[i + 1] -- 442
			local message = cloned[idx + 1] -- 443
			local minBudget = message.role == "system" and 96 or 192 -- 444
			local target = math.max( -- 445
				minBudget, -- 445
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 445
			) -- 445
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 446
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 447
			remainingContentBudget = math.max(0, remainingContentBudget) -- 448
			i = i - 1 -- 441
		end -- 441
	end -- 441
	local fittedTokens = estimateMessagesTokens(cloned) -- 451
	if fittedTokens > budgetTokens then -- 451
		do -- 451
			local i = 0 -- 453
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 453
				local idx = priorityIndexes[i + 1] -- 454
				local message = cloned[idx + 1] -- 455
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 456
				local excess = fittedTokens - budgetTokens -- 457
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 458
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 459
				fittedTokens = estimateMessagesTokens(cloned) -- 460
				i = i + 1 -- 453
			end -- 453
		end -- 453
	end -- 453
	if fittedTokens > budgetTokens then -- 453
		do -- 453
			local i = 0 -- 464
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 464
				do -- 464
					local idx = priorityIndexes[i + 1] -- 465
					if cloned[idx + 1].role == "system" then -- 465
						goto __continue123 -- 466
					end -- 466
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 467
					fittedTokens = estimateMessagesTokens(cloned) -- 468
				end -- 468
				::__continue123:: -- 468
				i = i + 1 -- 464
			end -- 464
		end -- 464
	end -- 464
	return { -- 471
		messages = cloned, -- 472
		trimmed = true, -- 473
		originalTokens = originalTokens, -- 474
		fittedTokens = fittedTokens, -- 475
		budgetTokens = budgetTokens -- 476
	} -- 476
end -- 392
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 480
	local requestTimeout = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT -- 490
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 491
	if stopToken == nil then -- 491
		stopToken = {stopped = false} -- 497
	end -- 497
	return __TS__New( -- 498
		__TS__Promise, -- 498
		function(____, resolve, reject) -- 498
			local requestId = 0 -- 499
			local settled = false -- 500
			local function finishResolve(text) -- 501
				if settled then -- 501
					return -- 502
				end -- 502
				settled = true -- 503
				resolve(nil, text) -- 504
			end -- 501
			local function finishReject(err) -- 506
				if settled then -- 506
					return -- 507
				end -- 507
				settled = true -- 508
				reject(nil, err) -- 509
			end -- 506
			Director.systemScheduler:schedule(function() -- 511
				if not settled then -- 511
					if stopToken.stopped then -- 511
						if requestId ~= 0 then -- 511
							HttpClient:cancel(requestId) -- 515
							requestId = 0 -- 516
						end -- 516
						finishReject("request cancelled") -- 518
						return true -- 519
					end -- 519
					return false -- 521
				end -- 521
				return true -- 523
			end) -- 511
			Director.systemScheduler:schedule(once(function() -- 525
				emit( -- 526
					"LLM_IN", -- 526
					table.concat( -- 526
						__TS__ArrayMap( -- 526
							messages, -- 526
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 526
						), -- 526
						"\n" -- 526
					) -- 526
				) -- 526
				local jsonStr, err = ____exports.safeJsonEncode(data) -- 527
				if jsonStr ~= nil then -- 527
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 529
					requestId = receiver and HttpClient:post( -- 534
						url, -- 535
						headers, -- 535
						jsonStr, -- 535
						requestTimeout, -- 535
						function(data) -- 535
							if stopToken.stopped then -- 535
								return true -- 536
							end -- 536
							return receiver(data) -- 537
						end, -- 535
						function(data) -- 538
							requestId = 0 -- 539
							if data ~= nil then -- 539
								finishResolve(data) -- 541
							else -- 541
								finishReject("failed to get http response") -- 543
							end -- 543
						end -- 538
					) or HttpClient:post( -- 538
						url, -- 546
						headers, -- 546
						jsonStr, -- 546
						requestTimeout, -- 546
						function(data) -- 546
							requestId = 0 -- 547
							if stopToken.stopped then -- 547
								finishReject("request cancelled") -- 549
								return -- 550
							end -- 550
							if data ~= nil then -- 550
								finishResolve(data) -- 553
							else -- 553
								finishReject("failed to get http response") -- 555
							end -- 555
						end -- 546
					) -- 546
					if requestId == 0 then -- 546
						finishReject("failed to schedule http request") -- 559
					elseif stopToken.stopped then -- 559
						HttpClient:cancel(requestId) -- 561
						requestId = 0 -- 562
						finishReject("request cancelled") -- 563
					end -- 563
				else -- 563
					finishReject(err) -- 566
				end -- 566
			end)) -- 525
		end -- 498
	) -- 498
end -- 480
function ____exports.createSSEJSONParser(opts) -- 576
	local buffer = "" -- 581
	local eventDataLines = {} -- 582
	local function flushEventIfAny() -- 584
		if #eventDataLines == 0 then -- 584
			return -- 585
		end -- 585
		local dataPayload = table.concat(eventDataLines, "\n") -- 587
		eventDataLines = {} -- 588
		if dataPayload == "[DONE]" then -- 588
			local ____opt_1 = opts.onDone -- 588
			if ____opt_1 ~= nil then -- 588
				____opt_1(dataPayload) -- 591
			end -- 591
			return -- 592
		end -- 592
		local obj, err = ____exports.safeJsonDecode(dataPayload) -- 595
		if err == nil then -- 595
			opts.onJSON(obj, dataPayload) -- 597
		else -- 597
			local ____opt_3 = opts.onError -- 597
			if ____opt_3 ~= nil then -- 597
				____opt_3(err, {raw = dataPayload}) -- 599
			end -- 599
		end -- 599
	end -- 584
	local function feed(chunk) -- 603
		buffer = buffer .. chunk -- 604
		while true do -- 604
			do -- 604
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 607
				if nl < 0 then -- 607
					break -- 608
				end -- 608
				local line = __TS__StringSlice(buffer, 0, nl) -- 610
				buffer = __TS__StringSlice(buffer, nl + 1) -- 611
				if __TS__StringEndsWith(line, "\r") then -- 611
					line = string.sub(line, 1, -2) -- 613
				end -- 613
				if line == "" then -- 613
					flushEventIfAny() -- 616
					goto __continue157 -- 617
				end -- 617
				if __TS__StringStartsWith(line, ":") then -- 617
					goto __continue157 -- 621
				end -- 621
				if __TS__StringStartsWith(line, "data:") then -- 621
					local v = string.sub(line, 6) -- 624
					if __TS__StringStartsWith(v, " ") then -- 624
						v = string.sub(v, 2) -- 625
					end -- 625
					eventDataLines[#eventDataLines + 1] = v -- 626
					goto __continue157 -- 627
				end -- 627
			end -- 627
			::__continue157:: -- 627
		end -- 627
	end -- 603
	local function ____end() -- 632
		if #buffer > 0 then -- 632
			local line = buffer -- 634
			buffer = "" -- 635
			if __TS__StringEndsWith(line, "\r") then -- 635
				line = string.sub(line, 1, -2) -- 636
			end -- 636
			if __TS__StringStartsWith(line, "data:") then -- 636
				local v = string.sub(line, 6) -- 639
				if __TS__StringStartsWith(v, " ") then -- 639
					v = string.sub(v, 2) -- 640
				end -- 640
				eventDataLines[#eventDataLines + 1] = v -- 641
			end -- 641
		end -- 641
		flushEventIfAny() -- 644
	end -- 632
	return {feed = feed, ["end"] = ____end} -- 647
end -- 576
local function normalizeContextWindow(value) -- 739
	if type(value) == "number" then -- 739
		return math.max( -- 741
			4000, -- 741
			math.floor(value) -- 741
		) -- 741
	end -- 741
	return 64000 -- 743
end -- 739
local function normalizeSupportsFunctionCalling(value) -- 746
	return value == nil or value == nil or value ~= 0 -- 747
end -- 746
function ____exports.getActiveLLMConfig() -- 750
	local rows = DB:query("select * from LLMConfig", true) -- 751
	local records = {} -- 752
	if rows and #rows > 1 then -- 752
		do -- 752
			local i = 1 -- 754
			while i < #rows do -- 754
				local record = {} -- 755
				do -- 755
					local c = 0 -- 756
					while c < #rows[i + 1] do -- 756
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 757
						c = c + 1 -- 756
					end -- 756
				end -- 756
				records[#records + 1] = record -- 759
				i = i + 1 -- 754
			end -- 754
		end -- 754
	end -- 754
	local config = __TS__ArrayFind( -- 762
		records, -- 762
		function(____, r) return r.active ~= 0 end -- 762
	) -- 762
	if not config then -- 762
		return {success = false, message = "no active LLM config"} -- 764
	end -- 764
	local url = config.url -- 764
	local model = config.model -- 764
	local api_key = config.api_key -- 764
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 764
		return {success = false, message = "got invalude LLM config"} -- 768
	end -- 768
	return { -- 770
		success = true, -- 771
		config = { -- 772
			url = url, -- 773
			model = model, -- 774
			apiKey = api_key, -- 775
			contextWindow = normalizeContextWindow(config.context_window), -- 776
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 777
		} -- 777
	} -- 777
end -- 750
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 782
	local callEvent -- 788
	if event.id ~= nil then -- 788
		local id = event.id -- 790
		callEvent = { -- 791
			id = nil, -- 792
			onData = function(data) -- 793
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 794
				return event.stopToken.stopped -- 795
			end, -- 793
			onCancel = function(reason) -- 797
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 798
			end, -- 797
			onDone = function() -- 800
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 801
			end -- 800
		} -- 800
	else -- 800
		callEvent = event -- 805
	end -- 805
	local ____callEvent_5 = callEvent -- 807
	local onData = ____callEvent_5.onData -- 807
	local onDone = ____callEvent_5.onDone -- 807
	local ____callEvent_6 = callEvent -- 808
	local onCancel = ____callEvent_6.onCancel -- 808
	local config = llmConfig or (function() -- 809
		local configRes = ____exports.getActiveLLMConfig() -- 810
		if not configRes.success then -- 810
			if onCancel then -- 810
				onCancel(configRes.message) -- 812
			end -- 812
			return nil -- 813
		end -- 813
		return configRes.config -- 815
	end)() -- 809
	if not config then -- 809
		return {success = false, message = "no active LLM config"} -- 818
	end -- 818
	local url = config.url -- 818
	local model = config.model -- 818
	local apiKey = config.apiKey -- 818
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 821
	if fitted.trimmed then -- 821
		____exports.Log( -- 823
			"Warn", -- 823
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 823
		) -- 823
	end -- 823
	local stopLLM = false -- 825
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 826
		local result = onData(obj) -- 828
		if result then -- 828
			stopLLM = result -- 829
		end -- 829
	end}); -- 827
	(function() -- 832
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 832
			local ____try = __TS__AsyncAwaiter(function() -- 832
				local ____array_8 = __TS__SparseArrayNew( -- 832
					fitted.messages, -- 834
					url, -- 834
					apiKey, -- 834
					model, -- 834
					options, -- 834
					true, -- 834
					function(data) -- 834
						if stopLLM then -- 834
							if onCancel then -- 834
								onCancel("LLM Stopped") -- 837
								onCancel = nil -- 838
							end -- 838
							return true -- 840
						end -- 840
						parser.feed(data) -- 842
						return false -- 843
					end -- 834
				) -- 834
				local ____temp_7 -- 844
				if event.stopToken ~= nil then -- 844
					____temp_7 = event.stopToken -- 844
				else -- 844
					____temp_7 = nil -- 844
				end -- 844
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 844
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 834
				parser["end"]() -- 845
				if onDone then -- 845
					onDone(result) -- 847
				end -- 847
			end) -- 847
			__TS__Await(____try.catch( -- 833
				____try, -- 833
				function(____, e) -- 833
					stopLLM = true -- 850
					if onCancel then -- 850
						onCancel(tostring(e)) -- 852
						onCancel = nil -- 853
					end -- 853
				end -- 853
			)) -- 853
		end) -- 853
	end)() -- 832
	return {success = true} -- 857
end -- 782
local function mergeStreamToolCall(target, delta) -- 860
	if type(delta.id) == "string" and delta.id ~= "" then -- 860
		target.id = delta.id -- 862
	end -- 862
	if type(delta.type) == "string" and delta.type ~= "" then -- 862
		target.type = delta.type -- 865
	end -- 865
	if delta["function"] then -- 865
		if target["function"] == nil then -- 865
			target["function"] = {} -- 868
		end -- 868
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then -- 868
			target["function"].name = (target["function"].name or "") .. delta["function"].name -- 870
		end -- 870
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then -- 870
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments -- 873
		end -- 873
	end -- 873
end -- 860
local function mergeStreamChoice(acc, choice) -- 878
	local delta = choice.delta or ({}) -- 879
	local fullMessage = choice.message or ({}) -- 880
	local message = acc.message -- 881
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil) -- 882
	if type(role) == "string" and role ~= "" then -- 882
		message.role = role -- 886
	end -- 886
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil) -- 888
	if type(content) == "string" and content ~= "" then -- 888
		message.content = (message.content or "") .. content -- 892
	end -- 892
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil) -- 894
	if type(reasoningContent) == "string" and reasoningContent ~= "" then -- 894
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent -- 898
	end -- 898
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({})) -- 900
	if toolCalls and #toolCalls > 0 then -- 900
		if message.tool_calls == nil then -- 900
			message.tool_calls = {} -- 904
		end -- 904
		do -- 904
			local i = 0 -- 905
			while i < #toolCalls do -- 905
				local item = toolCalls[i + 1] -- 906
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i -- 907
				local ____message_tool_calls_9, ____temp_10 = message.tool_calls, index + 1 -- 907
				if ____message_tool_calls_9[____temp_10] == nil then -- 907
					____message_tool_calls_9[____temp_10] = {} -- 910
				end -- 910
				mergeStreamToolCall(message.tool_calls[index + 1], item) -- 911
				i = i + 1 -- 905
			end -- 905
		end -- 905
	end -- 905
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then -- 905
		acc.finish_reason = choice.finish_reason -- 915
	end -- 915
end -- 878
local function buildStreamResponse(states, model, id, created, object, providerError) -- 919
	local indexes = __TS__ArraySort( -- 927
		__TS__ArrayFilter( -- 927
			__TS__ArrayMap( -- 927
				__TS__ObjectKeys(states), -- 927
				function(____, key) return __TS__Number(key) end -- 928
			), -- 928
			function(____, index) return __TS__NumberIsFinite(index) end -- 929
		), -- 929
		function(____, a, b) return a - b end -- 930
	) -- 930
	return { -- 931
		id = id, -- 932
		created = created, -- 933
		object = object, -- 934
		model = model, -- 935
		choices = __TS__ArrayMap( -- 936
			indexes, -- 936
			function(____, index) -- 936
				local state = states[index] -- 937
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason} -- 938
			end -- 936
		), -- 936
		error = providerError -- 949
	} -- 949
end -- 919
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk) -- 953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 953
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 960
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 961
		local resolvedConfig = config or (function() -- 964
			local configRes = ____exports.getActiveLLMConfig() -- 965
			if not configRes.success then -- 965
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message) -- 967
				return nil -- 968
			end -- 968
			return configRes.config -- 970
		end)() -- 964
		if not resolvedConfig then -- 964
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 964
		end -- 964
		local url = resolvedConfig.url -- 964
		local model = resolvedConfig.model -- 964
		local apiKey = resolvedConfig.apiKey -- 964
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 976
		____exports.Log( -- 977
			"Info", -- 977
			((((("[Agent.Utils] callLLMStreamAggregated request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 977
		) -- 977
		if stopToken and stopToken.stopped then -- 977
			local reason = stopToken.reason or "request cancelled" -- 979
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason) -- 980
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 980
		end -- 980
		local ____try = __TS__AsyncAwaiter(function() -- 980
			local states = {} -- 984
			local responseId = nil -- 985
			local responseCreated = nil -- 986
			local responseObject = nil -- 987
			local providerError -- 988
			local parser = ____exports.createSSEJSONParser({ -- 989
				onJSON = function(obj, raw) -- 990
					if not obj or type(obj) ~= "table" then -- 990
						return -- 992
					end -- 992
					local chunk = obj -- 994
					if chunk.error then -- 994
						providerError = chunk.error -- 996
						____exports.Log( -- 997
							"Warn", -- 997
							"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300) -- 997
						) -- 997
						return -- 998
					end -- 998
					responseId = type(chunk.id) == "string" and chunk.id or responseId -- 1000
					responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated -- 1001
					responseObject = type(chunk.object) == "string" and chunk.object or responseObject -- 1002
					local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({}) -- 1003
					do -- 1003
						local i = 0 -- 1004
						while i < #choices do -- 1004
							local choice = choices[i + 1] -- 1005
							local index = type(choice.index) == "number" and choice.index or i -- 1006
							if states[index] == nil then -- 1006
								states[index] = {index = index, message = {role = "assistant"}} -- 1007
							end -- 1007
							mergeStreamChoice(states[index], choice) -- 1011
							i = i + 1 -- 1004
						end -- 1004
					end -- 1004
					if onChunk ~= nil then -- 1004
						onChunk( -- 1013
							buildStreamResponse( -- 1014
								states, -- 1014
								model, -- 1014
								responseId, -- 1014
								responseCreated, -- 1014
								responseObject, -- 1014
								providerError -- 1014
							), -- 1014
							{ -- 1015
								id = chunk.id or "", -- 1016
								created = chunk.created or 0, -- 1017
								object = chunk.object or "", -- 1018
								model = chunk.model or model, -- 1019
								choices = choices -- 1020
							} -- 1020
						) -- 1020
					end -- 1020
				end, -- 990
				onError = function(err, context) -- 1024
					____exports.Log( -- 1025
						"Warn", -- 1025
						(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300) -- 1025
					) -- 1025
				end -- 1024
			}) -- 1024
			__TS__Await(postLLM( -- 1028
				fitted.messages, -- 1028
				url, -- 1028
				apiKey, -- 1028
				model, -- 1028
				options, -- 1028
				true, -- 1028
				function(data) -- 1028
					if stopToken and stopToken.stopped then -- 1028
						return true -- 1029
					end -- 1029
					parser.feed(data) -- 1030
					return false -- 1031
				end, -- 1028
				stopToken -- 1032
			)) -- 1032
			parser["end"]() -- 1033
			local response = buildStreamResponse( -- 1034
				states, -- 1034
				model, -- 1034
				responseId, -- 1034
				responseCreated, -- 1034
				responseObject, -- 1034
				providerError -- 1034
			) -- 1034
			local choiceCount = response.choices and #response.choices or 0 -- 1035
			____exports.Log( -- 1036
				"Info", -- 1036
				"[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount) -- 1036
			) -- 1036
			if not response.choices or #response.choices == 0 then -- 1036
				local providerMessage = providerError and providerError.message or "" -- 1038
				local providerType = providerError and providerError.type or "" -- 1039
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1040
				local details = table.concat( -- 1043
					__TS__ArrayFilter( -- 1043
						{providerType, providerCode}, -- 1043
						function(____, part) return part ~= "" end -- 1043
					), -- 1043
					"/" -- 1043
				) -- 1043
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices" -- 1044
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated empty choices") -- 1047
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1047
			end -- 1047
			return ____awaiter_resolve(nil, {success = true, response = response}) -- 1047
		end) -- 1047
		__TS__Await(____try.catch( -- 983
			____try, -- 983
			function(____, e) -- 983
				if stopToken and stopToken.stopped then -- 983
					local reason = stopToken.reason or "request cancelled" -- 1059
					____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason) -- 1060
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1060
				end -- 1060
				____exports.Log( -- 1063
					"Error", -- 1063
					"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e) -- 1063
				) -- 1063
				return ____awaiter_resolve( -- 1063
					nil, -- 1063
					{ -- 1064
						success = false, -- 1064
						message = tostring(e) -- 1064
					} -- 1064
				) -- 1064
			end -- 1064
		)) -- 1064
	end) -- 1064
end -- 953
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 1068
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1068
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 1074
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 1075
		local resolvedConfig = config or (function() -- 1078
			local configRes = ____exports.getActiveLLMConfig() -- 1079
			if not configRes.success then -- 1079
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 1081
				return nil -- 1082
			end -- 1082
			return configRes.config -- 1084
		end)() -- 1078
		if not resolvedConfig then -- 1078
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 1078
		end -- 1078
		local url = resolvedConfig.url -- 1078
		local model = resolvedConfig.model -- 1078
		local apiKey = resolvedConfig.apiKey -- 1078
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 1090
		____exports.Log( -- 1091
			"Info", -- 1091
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 1091
		) -- 1091
		if stopToken and stopToken.stopped then -- 1091
			local reason = stopToken.reason or "request cancelled" -- 1093
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 1094
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1094
		end -- 1094
		local ____try = __TS__AsyncAwaiter(function() -- 1094
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM( -- 1098
				fitted.messages, -- 1098
				url, -- 1098
				apiKey, -- 1098
				model, -- 1098
				options, -- 1098
				false, -- 1098
				nil, -- 1098
				stopToken -- 1098
			))) -- 1098
			____exports.Log( -- 1099
				"Info", -- 1099
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 1099
			) -- 1099
			local response, err = ____exports.safeJsonDecode(raw) -- 1100
			if err ~= nil or response == nil or type(response) ~= "table" then -- 1100
				local rawPreview = previewText(raw) -- 1102
				____exports.Log( -- 1103
					"Error", -- 1103
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 1103
				) -- 1103
				return ____awaiter_resolve( -- 1103
					nil, -- 1103
					{ -- 1104
						success = false, -- 1105
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 1106
						raw = raw -- 1107
					} -- 1107
				) -- 1107
			end -- 1107
			local responseObj = response -- 1110
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 1111
			____exports.Log( -- 1112
				"Info", -- 1112
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 1112
			) -- 1112
			if not responseObj.choices or #responseObj.choices == 0 then -- 1112
				local providerError = responseObj.error -- 1114
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 1115
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 1118
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 1121
				local details = table.concat( -- 1124
					__TS__ArrayFilter( -- 1124
						{providerType, providerCode}, -- 1124
						function(____, part) return part ~= "" end -- 1124
					), -- 1124
					"/" -- 1124
				) -- 1124
				local rawPreview = previewText(raw, 400) -- 1125
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 1126
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 1129
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 1129
			end -- 1129
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 1129
		end) -- 1129
		__TS__Await(____try.catch( -- 1097
			____try, -- 1097
			function(____, e) -- 1097
				if stopToken and stopToken.stopped then -- 1097
					local reason = stopToken.reason or "request cancelled" -- 1142
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 1143
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 1143
				end -- 1143
				____exports.Log( -- 1146
					"Error", -- 1146
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 1146
				) -- 1146
				return ____awaiter_resolve( -- 1146
					nil, -- 1146
					{ -- 1147
						success = false, -- 1147
						message = tostring(e) -- 1147
					} -- 1147
				) -- 1147
			end -- 1147
		)) -- 1147
	end) -- 1147
end -- 1068
return ____exports -- 1068