-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
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
local LOG_LEVEL = 3 -- 4
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
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" -- 41
local TOOL_CALL_ID_COUNTER = 0 -- 42
local function toBase36(value) -- 44
	if value <= 0 then -- 44
		return "0" -- 45
	end -- 45
	local remaining = math.floor(value) -- 46
	local out = "" -- 47
	while remaining > 0 do -- 47
		local digit = remaining % 36 -- 49
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out -- 50
		remaining = math.floor(remaining / 36) -- 51
	end -- 51
	return out -- 53
end -- 44
function ____exports.createLocalToolCallId() -- 56
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1 -- 57
	local timePart = toBase36(os.time()) -- 58
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER) -- 59
	return ("tc" .. timePart) .. counterPart -- 60
end -- 56
local function previewText(text, maxLen) -- 68
	if maxLen == nil then -- 68
		maxLen = 200 -- 68
	end -- 68
	if not text then -- 68
		return "" -- 69
	end -- 69
	local compact = __TS__StringReplace( -- 70
		__TS__StringReplace(text, "\r", "\\r"), -- 70
		"\n", -- 70
		"\\n" -- 70
	) -- 70
	if #compact <= maxLen then -- 70
		return compact -- 71
	end -- 71
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 72
end -- 68
local function utf8TakeHead(text, maxChars) -- 75
	if maxChars <= 0 or text == "" then -- 75
		return "" -- 76
	end -- 76
	local nextPos = utf8.offset(text, maxChars + 1) -- 77
	if nextPos == nil then -- 77
		return text -- 78
	end -- 78
	return string.sub(text, 1, nextPos - 1) -- 79
end -- 75
local function utf8TakeTail(text, maxChars) -- 82
	if maxChars <= 0 or text == "" then -- 82
		return "" -- 83
	end -- 83
	local charLen = utf8.len(text) -- 84
	if charLen == false or charLen <= maxChars then -- 84
		return text -- 85
	end -- 85
	local startChar = math.max(1, charLen - maxChars + 1) -- 86
	local startPos = utf8.offset(text, startChar) -- 87
	if startPos == nil then -- 87
		return text -- 88
	end -- 88
	return string.sub(text, startPos) -- 89
end -- 82
function ____exports.estimateTextTokens(text) -- 92
	if not text then -- 92
		return 0 -- 93
	end -- 93
	local charLen = utf8.len(text) -- 94
	if charLen == false or charLen <= 0 then -- 94
		return 0 -- 95
	end -- 95
	local otherChars = #text - charLen -- 96
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 97
	return math.max(1, tokens) -- 98
end -- 92
local function estimateMessagesTokens(messages) -- 101
	local total = 0 -- 102
	do -- 102
		local i = 0 -- 103
		while i < #messages do -- 103
			local message = messages[i + 1] -- 104
			total = total + 8 -- 105
			total = total + ____exports.estimateTextTokens(message.role or "") -- 106
			total = total + ____exports.estimateTextTokens(message.content or "") -- 107
			total = total + ____exports.estimateTextTokens(message.name or "") -- 108
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "") -- 109
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "") -- 110
			local toolCallsText = json.encode(message.tool_calls or ({})) -- 111
			total = total + ____exports.estimateTextTokens(toolCallsText or "") -- 112
			i = i + 1 -- 103
		end -- 103
	end -- 103
	return total -- 114
end -- 101
local function estimateOptionsTokens(options) -- 117
	local text = json.encode(options) -- 118
	return text and ____exports.estimateTextTokens(text) or 0 -- 119
end -- 117
local function getReservedOutputTokens(options, contextWindow) -- 122
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 123
	if explicitMax > 0 then -- 123
		return math.max(256, explicitMax) -- 128
	end -- 128
	return math.max( -- 129
		1024, -- 129
		math.floor(contextWindow * 0.2) -- 129
	) -- 129
end -- 122
local function getInputTokenBudget(messages, options, config) -- 132
	local contextWindow = math.max(4000, config.contextWindow) -- 133
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 134
	local optionTokens = estimateOptionsTokens(options) -- 135
	local structuralOverhead = math.max(256, #messages * 16) -- 136
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 137
end -- 132
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 140
	if budgetTokens <= 0 or text == "" then -- 140
		return "" -- 141
	end -- 141
	local estimated = ____exports.estimateTextTokens(text) -- 142
	if estimated <= budgetTokens then -- 142
		return text -- 143
	end -- 143
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 144
	local targetChars = math.max( -- 145
		200, -- 145
		math.floor(budgetTokens * charsPerToken) -- 145
	) -- 145
	local keepHead = math.max( -- 146
		0, -- 146
		math.floor(targetChars * 0.35) -- 146
	) -- 146
	local keepTail = math.max(0, targetChars - keepHead) -- 147
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 148
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 149
	return (head .. "\n...\n") .. tail -- 150
end -- 140
function ____exports.fitMessagesToContext(messages, options, config) -- 153
	local cloned = __TS__ArrayMap( -- 160
		messages, -- 160
		function(____, message) return __TS__ObjectAssign({}, message) end -- 160
	) -- 160
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 161
	local originalTokens = estimateMessagesTokens(cloned) -- 162
	if originalTokens <= budgetTokens then -- 162
		return { -- 164
			messages = cloned, -- 165
			trimmed = false, -- 166
			originalTokens = originalTokens, -- 167
			fittedTokens = originalTokens, -- 168
			budgetTokens = budgetTokens -- 169
		} -- 169
	end -- 169
	local function roleOverhead(message) -- 173
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 173
	end -- 173
	local fixedOverhead = 0 -- 174
	local contentIndexes = {} -- 175
	do -- 175
		local i = 0 -- 176
		while i < #cloned do -- 176
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 177
			contentIndexes[#contentIndexes + 1] = i -- 178
			i = i + 1 -- 176
		end -- 176
	end -- 176
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 180
	if #contentIndexes == 1 then -- 180
		local idx = contentIndexes[1] -- 182
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 183
		local fittedTokens = estimateMessagesTokens(cloned) -- 184
		return { -- 185
			messages = cloned, -- 186
			trimmed = true, -- 187
			originalTokens = originalTokens, -- 188
			fittedTokens = fittedTokens, -- 189
			budgetTokens = budgetTokens -- 190
		} -- 190
	end -- 190
	local nonSystemIndexes = {} -- 194
	local systemIndexes = {} -- 195
	do -- 195
		local i = 0 -- 196
		while i < #cloned do -- 196
			if cloned[i + 1].role == "system" then -- 196
				systemIndexes[#systemIndexes + 1] = i -- 197
			else -- 197
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 198
			end -- 198
			i = i + 1 -- 196
		end -- 196
	end -- 196
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 196
	__TS__SparseArrayPush( -- 196
		____array_0, -- 196
		table.unpack(systemIndexes) -- 200
	) -- 200
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 200
	local remainingContentBudget = contentBudget -- 201
	do -- 201
		local i = #priorityIndexes - 1 -- 202
		while i >= 0 do -- 202
			local idx = priorityIndexes[i + 1] -- 203
			local message = cloned[idx + 1] -- 204
			local minBudget = message.role == "system" and 96 or 192 -- 205
			local target = math.max( -- 206
				minBudget, -- 206
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 206
			) -- 206
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 207
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 208
			remainingContentBudget = math.max(0, remainingContentBudget) -- 209
			i = i - 1 -- 202
		end -- 202
	end -- 202
	local fittedTokens = estimateMessagesTokens(cloned) -- 212
	if fittedTokens > budgetTokens then -- 212
		do -- 212
			local i = 0 -- 214
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 214
				local idx = priorityIndexes[i + 1] -- 215
				local message = cloned[idx + 1] -- 216
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 217
				local excess = fittedTokens - budgetTokens -- 218
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 219
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 220
				fittedTokens = estimateMessagesTokens(cloned) -- 221
				i = i + 1 -- 214
			end -- 214
		end -- 214
	end -- 214
	if fittedTokens > budgetTokens then -- 214
		do -- 214
			local i = 0 -- 225
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 225
				do -- 225
					local idx = priorityIndexes[i + 1] -- 226
					if cloned[idx + 1].role == "system" then -- 226
						goto __continue53 -- 227
					end -- 227
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 228
					fittedTokens = estimateMessagesTokens(cloned) -- 229
				end -- 229
				::__continue53:: -- 229
				i = i + 1 -- 225
			end -- 225
		end -- 225
	end -- 225
	return { -- 232
		messages = cloned, -- 233
		trimmed = true, -- 234
		originalTokens = originalTokens, -- 235
		fittedTokens = fittedTokens, -- 236
		budgetTokens = budgetTokens -- 237
	} -- 237
end -- 153
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 241
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 251
	if stopToken == nil then -- 251
		stopToken = {stopped = false} -- 257
	end -- 257
	return __TS__New( -- 258
		__TS__Promise, -- 258
		function(____, resolve, reject) -- 258
			local requestId = 0 -- 259
			local settled = false -- 260
			local function finishResolve(text) -- 261
				if settled then -- 261
					return -- 262
				end -- 262
				settled = true -- 263
				resolve(nil, text) -- 264
			end -- 261
			local function finishReject(err) -- 266
				if settled then -- 266
					return -- 267
				end -- 267
				settled = true -- 268
				reject(nil, err) -- 269
			end -- 266
			Director.systemScheduler:schedule(function() -- 271
				if not settled then -- 271
					if stopToken.stopped then -- 271
						if requestId ~= 0 then -- 271
							HttpClient:cancel(requestId) -- 275
							requestId = 0 -- 276
						end -- 276
						finishReject("request cancelled") -- 278
						return true -- 279
					end -- 279
					return false -- 281
				end -- 281
				return true -- 283
			end) -- 271
			Director.systemScheduler:schedule(once(function() -- 285
				emit( -- 286
					"LLM_IN", -- 286
					table.concat( -- 286
						__TS__ArrayMap( -- 286
							messages, -- 286
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end -- 286
						), -- 286
						"\n" -- 286
					) -- 286
				) -- 286
				local jsonStr, err = json.encode(data) -- 287
				if jsonStr ~= nil then -- 287
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 289
					requestId = receiver and HttpClient:post( -- 294
						url, -- 295
						headers, -- 295
						jsonStr, -- 295
						LLM_TIMEOUT, -- 295
						function(data) -- 295
							if stopToken.stopped then -- 295
								return true -- 296
							end -- 296
							return receiver(data) -- 297
						end, -- 295
						function(data) -- 298
							requestId = 0 -- 299
							if data ~= nil then -- 299
								finishResolve(data) -- 301
							else -- 301
								finishReject("failed to get http response") -- 303
							end -- 303
						end -- 298
					) or HttpClient:post( -- 298
						url, -- 306
						headers, -- 306
						jsonStr, -- 306
						LLM_TIMEOUT, -- 306
						function(data) -- 306
							requestId = 0 -- 307
							if stopToken.stopped then -- 307
								finishReject("request cancelled") -- 309
								return -- 310
							end -- 310
							if data ~= nil then -- 310
								finishResolve(data) -- 313
							else -- 313
								finishReject("failed to get http response") -- 315
							end -- 315
						end -- 306
					) -- 306
					if requestId == 0 then -- 306
						finishReject("failed to schedule http request") -- 319
					elseif stopToken.stopped then -- 319
						HttpClient:cancel(requestId) -- 321
						requestId = 0 -- 322
						finishReject("request cancelled") -- 323
					end -- 323
				else -- 323
					finishReject(err) -- 326
				end -- 326
			end)) -- 285
		end -- 258
	) -- 258
end -- 241
function ____exports.createSSEJSONParser(opts) -- 336
	local buffer = "" -- 341
	local eventDataLines = {} -- 342
	local function flushEventIfAny() -- 344
		if #eventDataLines == 0 then -- 344
			return -- 345
		end -- 345
		local dataPayload = table.concat(eventDataLines, "\n") -- 347
		eventDataLines = {} -- 348
		if dataPayload == "[DONE]" then -- 348
			local ____opt_1 = opts.onDone -- 348
			if ____opt_1 ~= nil then -- 348
				____opt_1(dataPayload) -- 351
			end -- 351
			return -- 352
		end -- 352
		local obj, err = json.decode(dataPayload) -- 355
		if err == nil then -- 355
			opts.onJSON(obj, dataPayload) -- 357
		else -- 357
			local ____opt_3 = opts.onError -- 357
			if ____opt_3 ~= nil then -- 357
				____opt_3(err, {raw = dataPayload}) -- 359
			end -- 359
		end -- 359
	end -- 344
	local function feed(chunk) -- 363
		buffer = buffer .. chunk -- 364
		while true do -- 364
			do -- 364
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 367
				if nl < 0 then -- 367
					break -- 368
				end -- 368
				local line = __TS__StringSlice(buffer, 0, nl) -- 370
				buffer = __TS__StringSlice(buffer, nl + 1) -- 371
				if __TS__StringEndsWith(line, "\r") then -- 371
					line = string.sub(line, 1, -2) -- 373
				end -- 373
				if line == "" then -- 373
					flushEventIfAny() -- 376
					goto __continue87 -- 377
				end -- 377
				if __TS__StringStartsWith(line, ":") then -- 377
					goto __continue87 -- 381
				end -- 381
				if __TS__StringStartsWith(line, "data:") then -- 381
					local v = string.sub(line, 6) -- 384
					if __TS__StringStartsWith(v, " ") then -- 384
						v = string.sub(v, 2) -- 385
					end -- 385
					eventDataLines[#eventDataLines + 1] = v -- 386
					goto __continue87 -- 387
				end -- 387
			end -- 387
			::__continue87:: -- 387
		end -- 387
	end -- 363
	local function ____end() -- 392
		if #buffer > 0 then -- 392
			local line = buffer -- 394
			buffer = "" -- 395
			if __TS__StringEndsWith(line, "\r") then -- 395
				line = string.sub(line, 1, -2) -- 396
			end -- 396
			if __TS__StringStartsWith(line, "data:") then -- 396
				local v = string.sub(line, 6) -- 399
				if __TS__StringStartsWith(v, " ") then -- 399
					v = string.sub(v, 2) -- 400
				end -- 400
				eventDataLines[#eventDataLines + 1] = v -- 401
			end -- 401
		end -- 401
		flushEventIfAny() -- 404
	end -- 392
	return {feed = feed, ["end"] = ____end} -- 407
end -- 336
local function normalizeContextWindow(value) -- 476
	if type(value) == "number" then -- 476
		return math.max( -- 478
			4000, -- 478
			math.floor(value) -- 478
		) -- 478
	end -- 478
	return 64000 -- 480
end -- 476
local function normalizeSupportsFunctionCalling(value) -- 483
	return value == nil or value == nil or value ~= 0 -- 484
end -- 483
function ____exports.getActiveLLMConfig() -- 487
	local rows = DB:query("select * from LLMConfig", true) -- 488
	local records = {} -- 489
	if rows and #rows > 1 then -- 489
		do -- 489
			local i = 1 -- 491
			while i < #rows do -- 491
				local record = {} -- 492
				do -- 492
					local c = 0 -- 493
					while c < #rows[i + 1] do -- 493
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 494
						c = c + 1 -- 493
					end -- 493
				end -- 493
				records[#records + 1] = record -- 496
				i = i + 1 -- 491
			end -- 491
		end -- 491
	end -- 491
	local config = __TS__ArrayFind( -- 499
		records, -- 499
		function(____, r) return r.active ~= 0 end -- 499
	) -- 499
	if not config then -- 499
		return {success = false, message = "no active LLM config"} -- 501
	end -- 501
	local url = config.url -- 501
	local model = config.model -- 501
	local api_key = config.api_key -- 501
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 501
		return {success = false, message = "got invalude LLM config"} -- 505
	end -- 505
	return { -- 507
		success = true, -- 508
		config = { -- 509
			url = url, -- 510
			model = model, -- 511
			apiKey = api_key, -- 512
			contextWindow = normalizeContextWindow(config.context_window), -- 513
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling) -- 514
		} -- 514
	} -- 514
end -- 487
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 519
	local callEvent -- 525
	if event.id ~= nil then -- 525
		local id = event.id -- 527
		callEvent = { -- 528
			id = nil, -- 529
			onData = function(data) -- 530
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 531
				return event.stopToken.stopped -- 532
			end, -- 530
			onCancel = function(reason) -- 534
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 535
			end, -- 534
			onDone = function() -- 537
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 538
			end -- 537
		} -- 537
	else -- 537
		callEvent = event -- 542
	end -- 542
	local ____callEvent_5 = callEvent -- 544
	local onData = ____callEvent_5.onData -- 544
	local onDone = ____callEvent_5.onDone -- 544
	local ____callEvent_6 = callEvent -- 545
	local onCancel = ____callEvent_6.onCancel -- 545
	local config = llmConfig or (function() -- 546
		local configRes = ____exports.getActiveLLMConfig() -- 547
		if not configRes.success then -- 547
			if onCancel then -- 547
				onCancel(configRes.message) -- 549
			end -- 549
			return nil -- 550
		end -- 550
		return configRes.config -- 552
	end)() -- 546
	if not config then -- 546
		return {success = false, message = "no active LLM config"} -- 555
	end -- 555
	local url = config.url -- 555
	local model = config.model -- 555
	local apiKey = config.apiKey -- 555
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 558
	if fitted.trimmed then -- 558
		____exports.Log( -- 560
			"Warn", -- 560
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 560
		) -- 560
	end -- 560
	local stopLLM = false -- 562
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 563
		local result = onData(obj) -- 565
		if result then -- 565
			stopLLM = result -- 566
		end -- 566
	end}); -- 564
	(function() -- 569
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 569
			local ____try = __TS__AsyncAwaiter(function() -- 569
				local ____array_8 = __TS__SparseArrayNew( -- 569
					fitted.messages, -- 571
					url, -- 571
					apiKey, -- 571
					model, -- 571
					options, -- 571
					true, -- 571
					function(data) -- 571
						if stopLLM then -- 571
							if onCancel then -- 571
								onCancel("LLM Stopped") -- 574
								onCancel = nil -- 575
							end -- 575
							return true -- 577
						end -- 577
						parser.feed(data) -- 579
						return false -- 580
					end -- 571
				) -- 571
				local ____temp_7 -- 581
				if event.stopToken ~= nil then -- 581
					____temp_7 = event.stopToken -- 581
				else -- 581
					____temp_7 = nil -- 581
				end -- 581
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 581
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 571
				parser["end"]() -- 582
				if onDone then -- 582
					onDone(result) -- 584
				end -- 584
			end) -- 584
			__TS__Await(____try.catch( -- 570
				____try, -- 570
				function(____, e) -- 570
					stopLLM = true -- 587
					if onCancel then -- 587
						onCancel(tostring(e)) -- 589
						onCancel = nil -- 590
					end -- 590
				end -- 590
			)) -- 590
		end) -- 590
	end)() -- 569
	return {success = true} -- 594
end -- 519
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 597
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 603
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 604
		local resolvedConfig = config or (function() -- 607
			local configRes = ____exports.getActiveLLMConfig() -- 608
			if not configRes.success then -- 608
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 610
				return nil -- 611
			end -- 611
			return configRes.config -- 613
		end)() -- 607
		if not resolvedConfig then -- 607
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 607
		end -- 607
		local url = resolvedConfig.url -- 607
		local model = resolvedConfig.model -- 607
		local apiKey = resolvedConfig.apiKey -- 607
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 619
		____exports.Log( -- 620
			"Info", -- 620
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 620
		) -- 620
		if stopToken and stopToken.stopped then -- 620
			local reason = stopToken.reason or "request cancelled" -- 622
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 623
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 623
		end -- 623
		local ____try = __TS__AsyncAwaiter(function() -- 623
			local raw = __TS__Await(postLLM( -- 627
				fitted.messages, -- 627
				url, -- 627
				apiKey, -- 627
				model, -- 627
				options, -- 627
				false, -- 627
				nil, -- 627
				stopToken -- 627
			)) -- 627
			____exports.Log( -- 628
				"Info", -- 628
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 628
			) -- 628
			local response, err = json.decode(raw) -- 629
			if err ~= nil or response == nil or type(response) ~= "table" then -- 629
				local rawPreview = previewText(raw) -- 631
				____exports.Log( -- 632
					"Error", -- 632
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 632
				) -- 632
				return ____awaiter_resolve( -- 632
					nil, -- 632
					{ -- 633
						success = false, -- 634
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 635
						raw = raw -- 636
					} -- 636
				) -- 636
			end -- 636
			local responseObj = response -- 639
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 640
			____exports.Log( -- 641
				"Info", -- 641
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 641
			) -- 641
			if not responseObj.choices or #responseObj.choices == 0 then -- 641
				local providerError = responseObj.error -- 643
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 644
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 647
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 650
				local details = table.concat( -- 653
					__TS__ArrayFilter( -- 653
						{providerType, providerCode}, -- 653
						function(____, part) return part ~= "" end -- 653
					), -- 653
					"/" -- 653
				) -- 653
				local rawPreview = previewText(raw, 400) -- 654
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 655
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 658
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 658
			end -- 658
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 658
		end) -- 658
		__TS__Await(____try.catch( -- 626
			____try, -- 626
			function(____, e) -- 626
				if stopToken and stopToken.stopped then -- 626
					local reason = stopToken.reason or "request cancelled" -- 671
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 672
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 672
				end -- 672
				____exports.Log( -- 675
					"Error", -- 675
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 675
				) -- 675
				return ____awaiter_resolve( -- 675
					nil, -- 675
					{ -- 676
						success = false, -- 676
						message = tostring(e) -- 676
					} -- 676
				) -- 676
			end -- 676
		)) -- 676
	end) -- 676
end -- 597
return ____exports -- 597