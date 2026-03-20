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
local function getActiveLLMConfig() -- 277
	local rows = DB:query("select * from LLMConfig", true) -- 278
	local records = {} -- 279
	if rows and #rows > 1 then -- 279
		do -- 279
			local i = 1 -- 281
			while i < #rows do -- 281
				local record = {} -- 282
				do -- 282
					local c = 0 -- 283
					while c < #rows[i + 1] do -- 283
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 284
						c = c + 1 -- 283
					end -- 283
				end -- 283
				records[#records + 1] = record -- 286
				i = i + 1 -- 281
			end -- 281
		end -- 281
	end -- 281
	local config = __TS__ArrayFind( -- 289
		records, -- 289
		function(____, r) return r.active ~= 0 end -- 289
	) -- 289
	if not config then -- 289
		return {success = false, message = "no active LLM config"} -- 291
	end -- 291
	local url = config.url -- 291
	local model = config.model -- 291
	local api_key = config.api_key -- 291
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 291
		return {success = false, message = "got invalude LLM config"} -- 295
	end -- 295
	return {success = true, config = {url = url, model = model, api_key = api_key}} -- 297
end -- 277
____exports.callLLMStream = function(messages, options, event) -- 307
	local callEvent -- 308
	if event.id ~= nil then -- 308
		local id = event.id -- 310
		callEvent = { -- 311
			id = nil, -- 312
			onData = function(data) -- 313
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 314
				return event.stopToken.stopped -- 315
			end, -- 313
			onCancel = function(reason) -- 317
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 318
			end, -- 317
			onDone = function() -- 320
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 321
			end -- 320
		} -- 320
	else -- 320
		callEvent = event -- 325
	end -- 325
	local ____callEvent_4 = callEvent -- 327
	local onData = ____callEvent_4.onData -- 327
	local onDone = ____callEvent_4.onDone -- 327
	local ____callEvent_5 = callEvent -- 328
	local onCancel = ____callEvent_5.onCancel -- 328
	local configRes = getActiveLLMConfig() -- 329
	if not configRes.success then -- 329
		if onCancel then -- 329
			onCancel(configRes.message) -- 331
		end -- 331
		return {success = false, message = configRes.message} -- 332
	end -- 332
	local ____configRes_config_6 = configRes.config -- 334
	local url = ____configRes_config_6.url -- 334
	local model = ____configRes_config_6.model -- 334
	local api_key = ____configRes_config_6.api_key -- 334
	local stopLLM = false -- 335
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 336
		local result = onData(obj) -- 338
		if result then -- 338
			stopLLM = result -- 339
		end -- 339
	end}); -- 337
	(function() -- 342
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 342
			local ____try = __TS__AsyncAwaiter(function() -- 342
				local ____array_8 = __TS__SparseArrayNew( -- 342
					messages, -- 344
					url, -- 344
					api_key, -- 344
					model, -- 344
					options, -- 344
					true, -- 344
					function(data) -- 344
						if stopLLM then -- 344
							if onCancel then -- 344
								onCancel("LLM Stopped") -- 347
								onCancel = nil -- 348
							end -- 348
							return true -- 350
						end -- 350
						parser.feed(data) -- 352
						return false -- 353
					end -- 344
				) -- 344
				local ____temp_7 -- 354
				if event.stopToken ~= nil then -- 354
					____temp_7 = event.stopToken -- 354
				else -- 354
					____temp_7 = nil -- 354
				end -- 354
				__TS__SparseArrayPush(____array_8, ____temp_7) -- 354
				local result = __TS__Await(postLLM(__TS__SparseArraySpread(____array_8))) -- 344
				parser["end"]() -- 355
				if onDone then -- 355
					onDone(result) -- 357
				end -- 357
			end) -- 357
			__TS__Await(____try.catch( -- 343
				____try, -- 343
				function(____, e) -- 343
					stopLLM = true -- 360
					if onCancel then -- 360
						onCancel(tostring(e)) -- 362
						onCancel = nil -- 363
					end -- 363
				end -- 363
			)) -- 363
		end) -- 363
	end)() -- 342
	return {success = true} -- 367
end -- 307
function ____exports.callLLM(messages, options, stopToken) -- 370
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 370
		local configRes = getActiveLLMConfig() -- 375
		if not configRes.success then -- 375
			____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 377
			return ____awaiter_resolve(nil, {success = false, message = configRes.message}) -- 377
		end -- 377
		local ____configRes_config_9 = configRes.config -- 380
		local url = ____configRes_config_9.url -- 380
		local model = ____configRes_config_9.model -- 380
		local api_key = ____configRes_config_9.api_key -- 380
		____exports.Log( -- 381
			"Info", -- 381
			(((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages) -- 381
		) -- 381
		if stopToken and stopToken.stopped then -- 381
			local reason = stopToken.reason or "request cancelled" -- 383
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 384
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 384
		end -- 384
		local ____try = __TS__AsyncAwaiter(function() -- 384
			local raw = __TS__Await(postLLM( -- 388
				messages, -- 388
				url, -- 388
				api_key, -- 388
				model, -- 388
				options, -- 388
				false, -- 388
				nil, -- 388
				stopToken -- 388
			)) -- 388
			____exports.Log( -- 389
				"Info", -- 389
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 389
			) -- 389
			local response, err = json.decode(raw) -- 390
			if err ~= nil or response == nil or type(response) ~= "table" then -- 390
				local rawPreview = previewText(raw) -- 392
				____exports.Log( -- 393
					"Error", -- 393
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview -- 393
				) -- 393
				return ____awaiter_resolve( -- 393
					nil, -- 393
					{ -- 394
						success = false, -- 395
						message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview, -- 396
						raw = raw -- 397
					} -- 397
				) -- 397
			end -- 397
			local responseObj = response -- 400
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 401
			____exports.Log( -- 402
				"Info", -- 402
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 402
			) -- 402
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 402
		end) -- 402
		__TS__Await(____try.catch( -- 387
			____try, -- 387
			function(____, e) -- 387
				if stopToken and stopToken.stopped then -- 387
					local reason = stopToken.reason or "request cancelled" -- 409
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 410
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 410
				end -- 410
				____exports.Log( -- 413
					"Error", -- 413
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 413
				) -- 413
				return ____awaiter_resolve( -- 413
					nil, -- 413
					{ -- 414
						success = false, -- 414
						message = tostring(e) -- 414
					} -- 414
				) -- 414
			end -- 414
		)) -- 414
	end) -- 414
end -- 370
return ____exports -- 370