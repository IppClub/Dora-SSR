-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
local HttpClient = ____Dora.HttpClient -- 2
local DB = ____Dora.DB -- 2
local emit = ____Dora.emit -- 2
local DoraLog = ____Dora.Log -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local LOG_LEVEL = 2 -- 4
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
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 38
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 48
	if stopToken == nil then -- 48
		stopToken = {stopped = false} -- 54
	end -- 54
	return __TS__New( -- 55
		__TS__Promise, -- 55
		function(____, resolve, reject) -- 55
			local requestId = 0 -- 56
			local settled = false -- 57
			local function finishResolve(text) -- 58
				if settled then -- 58
					return -- 59
				end -- 59
				settled = true -- 60
				resolve(nil, text) -- 61
			end -- 58
			local function finishReject(err) -- 63
				if settled then -- 63
					return -- 64
				end -- 64
				settled = true -- 65
				reject(nil, err) -- 66
			end -- 63
			Director.systemScheduler:schedule(function() -- 68
				if not settled then -- 68
					if stopToken.stopped then -- 68
						if requestId ~= 0 then -- 68
							HttpClient:cancel(requestId) -- 72
							requestId = 0 -- 73
						end -- 73
						finishReject("request cancelled") -- 75
						return true -- 76
					end -- 76
					return false -- 78
				end -- 78
				return true -- 80
			end) -- 68
			Director.systemScheduler:schedule(once(function() -- 82
				emit( -- 83
					"LLM_IN", -- 83
					table.concat( -- 83
						__TS__ArrayMap( -- 83
							messages, -- 83
							function(____, m, i) return (tostring(i) .. ": ") .. m.content end -- 83
						), -- 83
						"\n" -- 83
					) -- 83
				) -- 83
				local jsonStr, err = json.encode(data) -- 84
				if jsonStr ~= nil then -- 84
					local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json", "Accept: application/json"} -- 86
					requestId = receiver and HttpClient:post( -- 91
						url, -- 92
						headers, -- 92
						jsonStr, -- 92
						LLM_TIMEOUT, -- 92
						function(data) -- 92
							if stopToken.stopped then -- 92
								return true -- 93
							end -- 93
							return receiver(data) -- 94
						end, -- 92
						function(data) -- 95
							requestId = 0 -- 96
							if data ~= nil then -- 96
								finishResolve(data) -- 98
							else -- 98
								finishReject("failed to get http response") -- 100
							end -- 100
						end -- 95
					) or HttpClient:post( -- 95
						url, -- 103
						headers, -- 103
						jsonStr, -- 103
						LLM_TIMEOUT, -- 103
						function(data) -- 103
							requestId = 0 -- 104
							if stopToken.stopped then -- 104
								finishReject("request cancelled") -- 106
								return -- 107
							end -- 107
							if data ~= nil then -- 107
								finishResolve(data) -- 110
							else -- 110
								finishReject("failed to get http response") -- 112
							end -- 112
						end -- 103
					) -- 103
					if requestId == 0 then -- 103
						finishReject("failed to schedule http request") -- 116
					elseif stopToken.stopped then -- 116
						HttpClient:cancel(requestId) -- 118
						requestId = 0 -- 119
						finishReject("request cancelled") -- 120
					end -- 120
				else -- 120
					finishReject(err) -- 123
				end -- 123
			end)) -- 82
		end -- 55
	) -- 55
end -- 38
function ____exports.createSSEJSONParser(opts) -- 133
	local buffer = "" -- 138
	local eventDataLines = {} -- 139
	local function flushEventIfAny() -- 141
		if #eventDataLines == 0 then -- 141
			return -- 142
		end -- 142
		local dataPayload = table.concat(eventDataLines, "\n") -- 144
		eventDataLines = {} -- 145
		if dataPayload == "[DONE]" then -- 145
			local ____opt_0 = opts.onDone -- 145
			if ____opt_0 ~= nil then -- 145
				____opt_0(dataPayload) -- 148
			end -- 148
			return -- 149
		end -- 149
		local obj, err = json.decode(dataPayload) -- 152
		if err == nil then -- 152
			opts.onJSON(obj, dataPayload) -- 154
		else -- 154
			local ____opt_2 = opts.onError -- 154
			if ____opt_2 ~= nil then -- 154
				____opt_2(err, {raw = dataPayload}) -- 156
			end -- 156
		end -- 156
	end -- 141
	local function feed(chunk) -- 160
		buffer = buffer .. chunk -- 161
		while true do -- 161
			do -- 161
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 164
				if nl < 0 then -- 164
					break -- 165
				end -- 165
				local line = __TS__StringSlice(buffer, 0, nl) -- 167
				buffer = __TS__StringSlice(buffer, nl + 1) -- 168
				if __TS__StringEndsWith(line, "\r") then -- 168
					line = string.sub(line, 1, -2) -- 170
				end -- 170
				if line == "" then -- 170
					flushEventIfAny() -- 173
					goto __continue43 -- 174
				end -- 174
				if __TS__StringStartsWith(line, ":") then -- 174
					goto __continue43 -- 178
				end -- 178
				if __TS__StringStartsWith(line, "data:") then -- 178
					local v = string.sub(line, 6) -- 181
					if __TS__StringStartsWith(v, " ") then -- 181
						v = string.sub(v, 2) -- 182
					end -- 182
					eventDataLines[#eventDataLines + 1] = v -- 183
					goto __continue43 -- 184
				end -- 184
			end -- 184
			::__continue43:: -- 184
		end -- 184
	end -- 160
	local function ____end() -- 189
		if #buffer > 0 then -- 189
			local line = buffer -- 191
			buffer = "" -- 192
			if __TS__StringEndsWith(line, "\r") then -- 192
				line = string.sub(line, 1, -2) -- 193
			end -- 193
			if __TS__StringStartsWith(line, "data:") then -- 193
				local v = string.sub(line, 6) -- 196
				if __TS__StringStartsWith(v, " ") then -- 196
					v = string.sub(v, 2) -- 197
				end -- 197
				eventDataLines[#eventDataLines + 1] = v -- 198
			end -- 198
		end -- 198
		flushEventIfAny() -- 201
	end -- 189
	return {feed = feed, ["end"] = ____end} -- 204
end -- 133
local function normalizeContextWindow(value) -- 278
	if type(value) == "number" then -- 278
		return math.max( -- 280
			4000, -- 280
			math.floor(value) -- 280
		) -- 280
	end -- 280
	return 32000 -- 282
end -- 278
function ____exports.getActiveLLMConfig() -- 285
	local rows = DB:query("select * from LLMConfig", true) -- 286
	local records = {} -- 287
	if rows and #rows > 1 then -- 287
		do -- 287
			local i = 1 -- 289
			while i < #rows do -- 289
				local record = {} -- 290
				do -- 290
					local c = 0 -- 291
					while c < #rows[i + 1] do -- 291
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 292
						c = c + 1 -- 291
					end -- 291
				end -- 291
				records[#records + 1] = record -- 294
				i = i + 1 -- 289
			end -- 289
		end -- 289
	end -- 289
	local config = __TS__ArrayFind( -- 297
		records, -- 297
		function(____, r) return r.active ~= 0 end -- 297
	) -- 297
	if not config then -- 297
		return {success = false, message = "no active LLM config"} -- 299
	end -- 299
	local url = config.url -- 299
	local model = config.model -- 299
	local api_key = config.api_key -- 299
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 299
		return {success = false, message = "got invalude LLM config"} -- 303
	end -- 303
	return { -- 305
		success = true, -- 306
		config = { -- 307
			url = url, -- 308
			model = model, -- 309
			apiKey = api_key, -- 310
			contextWindow = normalizeContextWindow(config.context_window) -- 311
		} -- 311
	} -- 311
end -- 285
____exports.callLLMStream = function(messages, options, event, llmConfig) -- 316
	local callEvent -- 322
	if event.id ~= nil then -- 322
		local id = event.id -- 324
		callEvent = { -- 325
			id = nil, -- 326
			onData = function(data) -- 327
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 328
				return event.stopToken.stopped -- 329
			end, -- 327
			onCancel = function(reason) -- 331
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 332
			end, -- 331
			onDone = function() -- 334
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 335
			end -- 334
		} -- 334
	else -- 334
		callEvent = event -- 339
	end -- 339
	local ____callEvent_4 = callEvent -- 341
	local onData = ____callEvent_4.onData -- 341
	local onDone = ____callEvent_4.onDone -- 341
	local ____callEvent_5 = callEvent -- 342
	local onCancel = ____callEvent_5.onCancel -- 342
	local config = llmConfig or (function() -- 343
		local configRes = ____exports.getActiveLLMConfig() -- 344
		if not configRes.success then -- 344
			if onCancel then -- 344
				onCancel(configRes.message) -- 346
			end -- 346
			return nil -- 347
		end -- 347
		return configRes.config -- 349
	end)() -- 343
	if not config then -- 343
		return {success = false, message = "no active LLM config"} -- 352
	end -- 352
	local url = config.url -- 352
	local model = config.model -- 352
	local apiKey = config.apiKey -- 352
	local stopLLM = false -- 355
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 356
		local result = onData(obj) -- 358
		if result then -- 358
			stopLLM = result -- 359
		end -- 359
	end}); -- 357
	(function() -- 362
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 362
			local ____try = __TS__AsyncAwaiter(function() -- 362
				local ____array_7 = __TS__SparseArrayNew( -- 362
					messages, -- 364
					url, -- 364
					apiKey, -- 364
					model, -- 364
					options, -- 364
					true, -- 364
					function(data) -- 364
						if stopLLM then -- 364
							if onCancel then -- 364
								onCancel("LLM Stopped") -- 367
								onCancel = nil -- 368
							end -- 368
							return true -- 370
						end -- 370
						parser.feed(data) -- 372
						return false -- 373
					end -- 364
				) -- 364
				local ____temp_6 -- 374
				if event.stopToken ~= nil then -- 374
					____temp_6 = event.stopToken -- 374
				else -- 374
					____temp_6 = nil -- 374
				end -- 374
				__TS__SparseArrayPush(____array_7, ____temp_6) -- 374
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_7))) -- 364
				parser["end"]() -- 375
				if onDone then -- 375
					onDone(result) -- 377
				end -- 377
			end) -- 377
			__TS__Await(____try.catch( -- 363
				____try, -- 363
				function(____, e) -- 363
					stopLLM = true -- 380
					if onCancel then -- 380
						onCancel(tostring(e)) -- 382
						onCancel = nil -- 383
					end -- 383
				end -- 383
			)) -- 383
		end) -- 383
	end)() -- 362
	return {success = true} -- 387
end -- 316
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig) -- 390
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 390
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil -- 396
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig -- 397
		local resolvedConfig = config or (function() -- 400
			local configRes = ____exports.getActiveLLMConfig() -- 401
			if not configRes.success then -- 401
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 403
				return nil -- 404
			end -- 404
			return configRes.config -- 406
		end)() -- 400
		if not resolvedConfig then -- 400
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"}) -- 400
		end -- 400
		local url = resolvedConfig.url -- 400
		local model = resolvedConfig.model -- 400
		local apiKey = resolvedConfig.apiKey -- 400
		____exports.Log( -- 412
			"Info", -- 412
			(((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages) -- 412
		) -- 412
		if stopToken and stopToken.stopped then -- 412
			local reason = stopToken.reason or "request cancelled" -- 414
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 415
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 415
		end -- 415
		local ____try = __TS__AsyncAwaiter(function() -- 415
			local raw = __TS__Await(postLLM( -- 419
				messages, -- 419
				url, -- 419
				apiKey, -- 419
				model, -- 419
				options, -- 419
				false, -- 419
				nil, -- 419
				stopToken -- 419
			)) -- 419
			____exports.Log( -- 420
				"Info", -- 420
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 420
			) -- 420
			local response, err = json.decode(raw) -- 421
			if err ~= nil or response == nil or type(response) ~= "table" then -- 421
				local rawPreview = previewText(raw) -- 423
				____exports.Log( -- 424
					"Error", -- 424
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 424
				) -- 424
				return ____awaiter_resolve( -- 424
					nil, -- 424
					{ -- 425
						success = false, -- 426
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 427
						raw = raw -- 428
					} -- 428
				) -- 428
			end -- 428
			local responseObj = response -- 431
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 432
			____exports.Log( -- 433
				"Info", -- 433
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 433
			) -- 433
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 433
		end) -- 433
		__TS__Await(____try.catch( -- 418
			____try, -- 418
			function(____, e) -- 418
				if stopToken and stopToken.stopped then -- 418
					local reason = stopToken.reason or "request cancelled" -- 440
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 441
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 441
				end -- 441
				____exports.Log( -- 444
					"Error", -- 444
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 444
				) -- 444
				return ____awaiter_resolve( -- 444
					nil, -- 444
					{ -- 445
						success = false, -- 445
						message = tostring(e) -- 445
					} -- 445
				) -- 445
			end -- 445
		)) -- 445
	end) -- 445
end -- 390
return ____exports -- 390