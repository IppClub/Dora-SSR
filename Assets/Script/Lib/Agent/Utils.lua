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
local function previewText(text, maxLen) -- 31
	if maxLen == nil then -- 31
		maxLen = 200 -- 31
	end -- 31
	if not text then -- 31
		return "" -- 32
	end -- 32
	local compact = __TS__StringReplace( -- 33
		__TS__StringReplace(text, "\r", "\\r"), -- 33
		"\n", -- 33
		"\\n" -- 33
	) -- 33
	if #compact <= maxLen then -- 33
		return compact -- 34
	end -- 34
	return __TS__StringSlice(compact, 0, maxLen) .. "..." -- 35
end -- 31
local function utf8TakeHead(text, maxChars) -- 38
	if maxChars <= 0 or text == "" then -- 38
		return "" -- 39
	end -- 39
	local nextPos = utf8.offset(text, maxChars + 1) -- 40
	if nextPos == nil then -- 40
		return text -- 41
	end -- 41
	return string.sub(text, 1, nextPos - 1) -- 42
end -- 38
local function utf8TakeTail(text, maxChars) -- 45
	if maxChars <= 0 or text == "" then -- 45
		return "" -- 46
	end -- 46
	local charLen = utf8.len(text) -- 47
	if charLen == false or charLen <= maxChars then -- 47
		return text -- 48
	end -- 48
	local startChar = math.max(1, charLen - maxChars + 1) -- 49
	local startPos = utf8.offset(text, startChar) -- 50
	if startPos == nil then -- 50
		return text -- 51
	end -- 51
	return string.sub(text, startPos) -- 52
end -- 45
function ____exports.estimateTextTokens(text) -- 55
	if not text then -- 55
		return 0 -- 56
	end -- 56
	local charLen = utf8.len(text) -- 57
	if charLen == false or charLen <= 0 then -- 57
		return 0 -- 58
	end -- 58
	local otherChars = #text - charLen -- 59
	local tokens = math.ceil(charLen / 1.5 + otherChars / 4) -- 60
	return math.max(1, tokens) -- 61
end -- 55
local function estimateMessagesTokens(messages) -- 64
	local total = 0 -- 65
	do -- 65
		local i = 0 -- 66
		while i < #messages do -- 66
			local message = messages[i + 1] -- 67
			total = total + 8 -- 68
			total = total + ____exports.estimateTextTokens(message.role or "") -- 69
			total = total + ____exports.estimateTextTokens(message.content or "") -- 70
			i = i + 1 -- 66
		end -- 66
	end -- 66
	return total -- 72
end -- 64
local function estimateOptionsTokens(options) -- 75
	local text = json.encode(options) -- 76
	return text and ____exports.estimateTextTokens(text) or 0 -- 77
end -- 75
local function getReservedOutputTokens(options, contextWindow) -- 80
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 81
	if explicitMax > 0 then -- 81
		return math.max(256, explicitMax) -- 86
	end -- 86
	return math.max( -- 87
		1024, -- 87
		math.floor(contextWindow * 0.2) -- 87
	) -- 87
end -- 80
local function getInputTokenBudget(messages, options, config) -- 90
	local contextWindow = math.max(4000, config.contextWindow) -- 91
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow) -- 92
	local optionTokens = estimateOptionsTokens(options) -- 93
	local structuralOverhead = math.max(256, #messages * 16) -- 94
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead) -- 95
end -- 90
function ____exports.clipTextToTokenBudget(text, budgetTokens) -- 98
	if budgetTokens <= 0 or text == "" then -- 98
		return "" -- 99
	end -- 99
	local estimated = ____exports.estimateTextTokens(text) -- 100
	if estimated <= budgetTokens then -- 100
		return text -- 101
	end -- 101
	local charsPerToken = estimated > 0 and #text / estimated or 4 -- 102
	local targetChars = math.max( -- 103
		200, -- 103
		math.floor(budgetTokens * charsPerToken) -- 103
	) -- 103
	local keepHead = math.max( -- 104
		0, -- 104
		math.floor(targetChars * 0.35) -- 104
	) -- 104
	local keepTail = math.max(0, targetChars - keepHead) -- 105
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or "" -- 106
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or "" -- 107
	return (head .. "\n...\n") .. tail -- 108
end -- 98
function ____exports.fitMessagesToContext(messages, options, config) -- 111
	local cloned = __TS__ArrayMap( -- 118
		messages, -- 118
		function(____, message) return __TS__ObjectAssign({}, message) end -- 118
	) -- 118
	local budgetTokens = getInputTokenBudget(cloned, options, config) -- 119
	local originalTokens = estimateMessagesTokens(cloned) -- 120
	if originalTokens <= budgetTokens then -- 120
		return { -- 122
			messages = cloned, -- 123
			trimmed = false, -- 124
			originalTokens = originalTokens, -- 125
			fittedTokens = originalTokens, -- 126
			budgetTokens = budgetTokens -- 127
		} -- 127
	end -- 127
	local function roleOverhead(message) -- 131
		return ____exports.estimateTextTokens(message.role or "") + 8 -- 131
	end -- 131
	local fixedOverhead = 0 -- 132
	local contentIndexes = {} -- 133
	do -- 133
		local i = 0 -- 134
		while i < #cloned do -- 134
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1]) -- 135
			contentIndexes[#contentIndexes + 1] = i -- 136
			i = i + 1 -- 134
		end -- 134
	end -- 134
	local contentBudget = math.max(64, budgetTokens - fixedOverhead) -- 138
	if #contentIndexes == 1 then -- 138
		local idx = contentIndexes[1] -- 140
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", contentBudget) -- 141
		local fittedTokens = estimateMessagesTokens(cloned) -- 142
		return { -- 143
			messages = cloned, -- 144
			trimmed = true, -- 145
			originalTokens = originalTokens, -- 146
			fittedTokens = fittedTokens, -- 147
			budgetTokens = budgetTokens -- 148
		} -- 148
	end -- 148
	local nonSystemIndexes = {} -- 152
	local systemIndexes = {} -- 153
	do -- 153
		local i = 0 -- 154
		while i < #cloned do -- 154
			if cloned[i + 1].role == "system" then -- 154
				systemIndexes[#systemIndexes + 1] = i -- 155
			else -- 155
				nonSystemIndexes[#nonSystemIndexes + 1] = i -- 156
			end -- 156
			i = i + 1 -- 154
		end -- 154
	end -- 154
	local ____array_0 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes)) -- 154
	__TS__SparseArrayPush( -- 154
		____array_0, -- 154
		table.unpack(systemIndexes) -- 158
	) -- 158
	local priorityIndexes = {__TS__SparseArraySpread(____array_0)} -- 158
	local remainingContentBudget = contentBudget -- 159
	do -- 159
		local i = #priorityIndexes - 1 -- 160
		while i >= 0 do -- 160
			local idx = priorityIndexes[i + 1] -- 161
			local message = cloned[idx + 1] -- 162
			local minBudget = message.role == "system" and 96 or 192 -- 163
			local target = math.max( -- 164
				minBudget, -- 164
				math.floor(remainingContentBudget / math.max(1, i + 1)) -- 164
			) -- 164
			message.content = ____exports.clipTextToTokenBudget(message.content or "", target) -- 165
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(message.content or "") -- 166
			remainingContentBudget = math.max(0, remainingContentBudget) -- 167
			i = i - 1 -- 160
		end -- 160
	end -- 160
	local fittedTokens = estimateMessagesTokens(cloned) -- 170
	if fittedTokens > budgetTokens then -- 170
		do -- 170
			local i = 0 -- 172
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 172
				local idx = priorityIndexes[i + 1] -- 173
				local message = cloned[idx + 1] -- 174
				local currentTokens = ____exports.estimateTextTokens(message.content or "") -- 175
				local excess = fittedTokens - budgetTokens -- 176
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16) -- 177
				message.content = ____exports.clipTextToTokenBudget(message.content or "", nextBudget) -- 178
				fittedTokens = estimateMessagesTokens(cloned) -- 179
				i = i + 1 -- 172
			end -- 172
		end -- 172
	end -- 172
	if fittedTokens > budgetTokens then -- 172
		do -- 172
			local i = 0 -- 183
			while i < #priorityIndexes and fittedTokens > budgetTokens do -- 183
				do -- 183
					local idx = priorityIndexes[i + 1] -- 184
					if cloned[idx + 1].role == "system" then -- 184
						goto __continue49 -- 185
					end -- 185
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(cloned[idx + 1].content or "", 48) -- 186
					fittedTokens = estimateMessagesTokens(cloned) -- 187
				end -- 187
				::__continue49:: -- 187
				i = i + 1 -- 183
			end -- 183
		end -- 183
	end -- 183
	return { -- 190
		messages = cloned, -- 191
		trimmed = true, -- 192
		originalTokens = originalTokens, -- 193
		fittedTokens = fittedTokens, -- 194
		budgetTokens = budgetTokens -- 195
	} -- 195
end -- 111
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 199
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 209
	if stopToken == nil then -- 209
		stopToken = {stopped = false} -- 215
	end -- 215
	return __TS__New( -- 216
		__TS__Promise, -- 216
		function(____, resolve, reject) -- 216
			local requestId = 0 -- 217
			local settled = false -- 218
			local function finishResolve(text) -- 219
				if settled then -- 219
					return -- 220
				end -- 220
				settled = true -- 221
				resolve(nil, text) -- 222
			end -- 219
			local function finishReject(err) -- 224
				if settled then -- 224
					return -- 225
				end -- 225
				settled = true -- 226
				reject(nil, err) -- 227
			end -- 224
			Director.systemScheduler:schedule(function() -- 229
				if not settled then -- 229
					if stopToken.stopped then -- 229
						if requestId ~= 0 then -- 229
							HttpClient:cancel(requestId) -- 233
							requestId = 0 -- 234
						end -- 234
						finishReject("request cancelled") -- 236
						return true -- 237
					end -- 237
					return false -- 239
				end -- 239
				return true -- 241
			end) -- 229
			Director.systemScheduler:schedule(once(function() -- 243
				emit( -- 244
					"LLM_IN", -- 244
					table.concat( -- 244
						__TS__ArrayMap( -- 244
							messages, -- 244
							function(____, m, i) return (tostring(i) .. ": ") .. m.content end -- 244
						), -- 244
						"\n" -- 244
					) -- 244
				) -- 244
				local jsonStr, err = json.encode(data) -- 245
				if jsonStr ~= nil then -- 245
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 247
					requestId = receiver and HttpClient:post( -- 252
						url, -- 253
						headers, -- 253
						jsonStr, -- 253
						LLM_TIMEOUT, -- 253
						function(data) -- 253
							if stopToken.stopped then -- 253
								return true -- 254
							end -- 254
							return receiver(data) -- 255
						end, -- 253
						function(data) -- 256
							requestId = 0 -- 257
							if data ~= nil then -- 257
								finishResolve(data) -- 259
							else -- 259
								finishReject("failed to get http response") -- 261
							end -- 261
						end -- 256
					) or HttpClient:post( -- 256
						url, -- 264
						headers, -- 264
						jsonStr, -- 264
						LLM_TIMEOUT, -- 264
						function(data) -- 264
							requestId = 0 -- 265
							if stopToken.stopped then -- 265
								finishReject("request cancelled") -- 267
								return -- 268
							end -- 268
							if data ~= nil then -- 268
								finishResolve(data) -- 271
							else -- 271
								finishReject("failed to get http response") -- 273
							end -- 273
						end -- 264
					) -- 264
					if requestId == 0 then -- 264
						finishReject("failed to schedule http request") -- 277
					elseif stopToken.stopped then -- 277
						HttpClient:cancel(requestId) -- 279
						requestId = 0 -- 280
						finishReject("request cancelled") -- 281
					end -- 281
				else -- 281
					finishReject(err) -- 284
				end -- 284
			end)) -- 243
		end -- 216
	) -- 216
end -- 199
function ____exports.createSSEJSONParser(opts) -- 294
	local buffer = "" -- 299
	local eventDataLines = {} -- 300
	local function flushEventIfAny() -- 302
		if #eventDataLines == 0 then -- 302
			return -- 303
		end -- 303
		local dataPayload = table.concat(eventDataLines, "\n") -- 305
		eventDataLines = {} -- 306
		if dataPayload == "[DONE]" then -- 306
			local ____opt_1 = opts.onDone -- 306
			if ____opt_1 ~= nil then -- 306
				____opt_1(dataPayload) -- 309
			end -- 309
			return -- 310
		end -- 310
		local obj, err = json.decode(dataPayload) -- 313
		if err == nil then -- 313
			opts.onJSON(obj, dataPayload) -- 315
		else -- 315
			local ____opt_3 = opts.onError -- 315
			if ____opt_3 ~= nil then -- 315
				____opt_3(err, {raw = dataPayload}) -- 317
			end -- 317
		end -- 317
	end -- 302
	local function feed(chunk) -- 321
		buffer = buffer .. chunk -- 322
		while true do -- 322
			do -- 322
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 325
				if nl < 0 then -- 325
					break -- 326
				end -- 326
				local line = __TS__StringSlice(buffer, 0, nl) -- 328
				buffer = __TS__StringSlice(buffer, nl + 1) -- 329
				if __TS__StringEndsWith(line, "\r") then -- 329
					line = string.sub(line, 1, -2) -- 331
				end -- 331
				if line == "" then -- 331
					flushEventIfAny() -- 334
					goto __continue83 -- 335
				end -- 335
				if __TS__StringStartsWith(line, ":") then -- 335
					goto __continue83 -- 339
				end -- 339
				if __TS__StringStartsWith(line, "data:") then -- 339
					local v = string.sub(line, 6) -- 342
					if __TS__StringStartsWith(v, " ") then -- 342
						v = string.sub(v, 2) -- 343
					end -- 343
					eventDataLines[#eventDataLines + 1] = v -- 344
					goto __continue83 -- 345
				end -- 345
			end -- 345
			::__continue83:: -- 345
		end -- 345
	end -- 321
	local function ____end() -- 350
		if #buffer > 0 then -- 350
			local line = buffer -- 352
			buffer = "" -- 353
			if __TS__StringEndsWith(line, "\r") then -- 353
				line = string.sub(line, 1, -2) -- 354
			end -- 354
			if __TS__StringStartsWith(line, "data:") then -- 354
				local v = string.sub(line, 6) -- 357
				if __TS__StringStartsWith(v, " ") then -- 357
					v = string.sub(v, 2) -- 358
				end -- 358
				eventDataLines[#eventDataLines + 1] = v -- 359
			end -- 359
		end -- 359
		flushEventIfAny() -- 362
	end -- 350
	return {feed = feed, ["end"] = ____end} -- 365
end -- 294
local function normalizeContextWindow(value) -- 444
	if type(value) == "number" then -- 444
		return math.max( -- 446
			4000, -- 446
			math.floor(value) -- 446
		) -- 446
	end -- 446
	return 64000 -- 448
end -- 444
function ____exports.getActiveLLMConfig() -- 451
	local rows = DB:query("select * from LLMConfig", true) -- 452
	local records = {} -- 453
	if rows and #rows > 1 then -- 453
		do -- 453
			local i = 1 -- 455
			while i < #rows do -- 455
				local record = {} -- 456
				do -- 456
					local c = 0 -- 457
					while c < #rows[i + 1] do -- 457
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 458
						c = c + 1 -- 457
					end -- 457
				end -- 457
				records[#records + 1] = record -- 460
				i = i + 1 -- 455
			end -- 455
		end -- 455
	end -- 455
	local config = __TS__ArrayFind( -- 463
		records, -- 463
		function(____, r) return r.active ~= 0 end -- 463
	) -- 463
	if not config then -- 463
		return {success = false, message = "no active LLM config"} -- 465
	end -- 465
	local url = config.url -- 465
	local model = config.model -- 465
	local api_key = config.api_key -- 465
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 465
		return {success = false, message = "got invalude LLM config"} -- 469
	end -- 469
	return { -- 471
		success = true, -- 472
		config = { -- 473
			url = url, -- 474
			model = model, -- 475
			apiKey = api_key, -- 476
			contextWindow = normalizeContextWindow(config.context_window) -- 477
		} -- 477
	} -- 477
end -- 451
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 482
	local callEvent -- 488
	if event.id ~= nil then -- 488
		local id = event.id -- 490
		callEvent = { -- 491
			id = nil, -- 492
			onData = function(data) -- 493
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 494
				return event.stopToken.stopped -- 495
			end, -- 493
			onCancel = function(reason) -- 497
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 498
			end, -- 497
			onDone = function() -- 500
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 501
			end -- 500
		} -- 500
	else -- 500
		callEvent = event -- 505
	end -- 505
	local ____callEvent_5 = callEvent -- 507
	local onData = ____callEvent_5.onData -- 507
	local onDone = ____callEvent_5.onDone -- 507
	local ____callEvent_6 = callEvent -- 508
	local onCancel = ____callEvent_6.onCancel -- 508
	local config = llmConfig or (function() -- 509
		local configRes = ____exports.getActiveLLMConfig() -- 510
		if not configRes.success then -- 510
			if onCancel then -- 510
				onCancel(configRes.message) -- 512
			end -- 512
			return nil -- 513
		end -- 513
		return configRes.config -- 515
	end)() -- 509
	if not config then -- 509
		return {success = false, message = "no active LLM config"} -- 518
	end -- 518
	local url = config.url -- 518
	local model = config.model -- 518
	local apiKey = config.apiKey -- 518
	local fitted = ____exports.fitMessagesToContext(messages, options, config) -- 521
	if fitted.trimmed then -- 521
		____exports.Log( -- 523
			"Warn", -- 523
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens) -- 523
		) -- 523
	end -- 523
	local stopLLM = false -- 525
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 526
		local result = onData(obj) -- 528
		if result then -- 528
			stopLLM = result -- 529
		end -- 529
	end}); -- 527
	(function() -- 532
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 532
			local ____try = __TS__AsyncAwaiter(function() -- 532
				local ____array_8 = __TS__SparseArrayNew( -- 532
					fitted.messages, -- 534
					url, -- 534
					apiKey, -- 534
					model, -- 534
					options, -- 534
					true, -- 534
					function(data) -- 534
						if stopLLM then -- 534
							if onCancel then -- 534
								onCancel("LLM Stopped") -- 537
								onCancel = nil -- 538
							end -- 538
							return true -- 540
						end -- 540
						parser.feed(data) -- 542
						return false -- 543
					end -- 534
				) -- 534
				local ____temp_7 -- 544
				if event.stopToken ~= nil then -- 544
					____temp_7 = event.stopToken -- 544
				else -- 544
					____temp_7 = nil -- 544
				end -- 544
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 544
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 534
				parser["end"]() -- 545
				if onDone then -- 545
					onDone(result) -- 547
				end -- 547
			end) -- 547
			__TS__Await(____try.catch( -- 533
				____try, -- 533
				function(____, e) -- 533
					stopLLM = true -- 550
					if onCancel then -- 550
						onCancel(tostring(e)) -- 552
						onCancel = nil -- 553
					end -- 553
				end -- 553
			)) -- 553
		end) -- 553
	end)() -- 532
	return {success = true} -- 557
end -- 482
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 560
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 566
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 567
		local resolvedConfig = config or (function() -- 570
			local configRes = ____exports.getActiveLLMConfig() -- 571
			if not configRes.success then -- 571
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 573
				return nil -- 574
			end -- 574
			return configRes.config -- 576
		end)() -- 570
		if not resolvedConfig then -- 570
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 570
		end -- 570
		local url = resolvedConfig.url -- 570
		local model = resolvedConfig.model -- 570
		local apiKey = resolvedConfig.apiKey -- 570
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig) -- 582
		____exports.Log( -- 583
			"Info", -- 583
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "") -- 583
		) -- 583
		if stopToken and stopToken.stopped then -- 583
			local reason = stopToken.reason or "request cancelled" -- 585
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 586
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 586
		end -- 586
		local ____try = __TS__AsyncAwaiter(function() -- 586
			local raw = __TS__Await(postLLM( -- 590
				fitted.messages, -- 590
				url, -- 590
				apiKey, -- 590
				model, -- 590
				options, -- 590
				false, -- 590
				nil, -- 590
				stopToken -- 590
			)) -- 590
			____exports.Log( -- 591
				"Info", -- 591
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 591
			) -- 591
			local response, err = json.decode(raw) -- 592
			if err ~= nil or response == nil or type(response) ~= "table" then -- 592
				local rawPreview = previewText(raw) -- 594
				____exports.Log( -- 595
					"Error", -- 595
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 595
				) -- 595
				return ____awaiter_resolve( -- 595
					nil, -- 595
					{ -- 596
						success = false, -- 597
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 598
						raw = raw -- 599
					} -- 599
				) -- 599
			end -- 599
			local responseObj = response -- 602
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 603
			____exports.Log( -- 604
				"Info", -- 604
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 604
			) -- 604
			if not responseObj.choices or #responseObj.choices == 0 then -- 604
				local providerError = responseObj.error -- 606
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or "" -- 607
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or "" -- 610
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or "" -- 613
				local details = table.concat( -- 616
					__TS__ArrayFilter( -- 616
						{providerType, providerCode}, -- 616
						function(____, part) return part ~= "" end -- 616
					), -- 616
					"/" -- 616
				) -- 616
				local rawPreview = previewText(raw, 400) -- 617
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview -- 618
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview) -- 621
				return ____awaiter_resolve(nil, {success = false, message = message, raw = raw}) -- 621
			end -- 621
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 621
		end) -- 621
		__TS__Await(____try.catch( -- 589
			____try, -- 589
			function(____, e) -- 589
				if stopToken and stopToken.stopped then -- 589
					local reason = stopToken.reason or "request cancelled" -- 634
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 635
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 635
				end -- 635
				____exports.Log( -- 638
					"Error", -- 638
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 638
				) -- 638
				return ____awaiter_resolve( -- 638
					nil, -- 638
					{ -- 639
						success = false, -- 639
						message = tostring(e) -- 639
					} -- 639
				) -- 639
			end -- 639
		)) -- 639
	end) -- 639
end -- 560
return ____exports -- 560