-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
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
local function postLLM(messages, url, apiKey, model, options, stream, receiver, stopToken) -- 31
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = stream}) -- 41
	if stopToken == nil then -- 41
		stopToken = {stopped = false} -- 47
	end -- 47
	return __TS__New( -- 48
		__TS__Promise, -- 48
		function(____, resolve, reject) -- 48
			local requestId = 0 -- 49
			local settled = false -- 50
			local function finishResolve(text) -- 51
				if settled then -- 51
					return -- 52
				end -- 52
				settled = true -- 53
				resolve(nil, text) -- 54
			end -- 51
			local function finishReject(err) -- 56
				if settled then -- 56
					return -- 57
				end -- 57
				settled = true -- 58
				reject(nil, err) -- 59
			end -- 56
			Director.systemScheduler:schedule(function() -- 61
				if not settled then -- 61
					if stopToken.stopped then -- 61
						if requestId ~= 0 then -- 61
							HttpClient:cancel(requestId) -- 65
							requestId = 0 -- 66
						end -- 66
						finishReject("request cancelled") -- 68
						return true -- 69
					end -- 69
					return false -- 71
				end -- 71
				return true -- 73
			end) -- 61
			Director.systemScheduler:schedule(once(function() -- 75
				emit( -- 76
					"LLM_IN", -- 76
					table.concat( -- 76
						__TS__ArrayMap( -- 76
							messages, -- 76
							function(____, m, i) return (tostring(i) .. ": ") .. m.content end -- 76
						), -- 76
						"\n" -- 76
					) -- 76
				) -- 76
				local jsonStr, err = json.encode(data) -- 77
				if jsonStr ~= nil then -- 77
					local headers = {"Authorization: Bearer " .. apiKey} -- 79
					requestId = receiver and HttpClient:post( -- 80
						url, -- 81
						headers, -- 81
						jsonStr, -- 81
						LLM_TIMEOUT, -- 81
						function(data) -- 81
							if stopToken.stopped then -- 81
								return true -- 82
							end -- 82
							return receiver(data) -- 83
						end, -- 81
						function(data) -- 84
							requestId = 0 -- 85
							if data ~= nil then -- 85
								finishResolve(data) -- 87
							else -- 87
								finishReject("failed to get http response") -- 89
							end -- 89
						end -- 84
					) or HttpClient:post( -- 84
						url, -- 92
						headers, -- 92
						jsonStr, -- 92
						LLM_TIMEOUT, -- 92
						function(data) -- 92
							requestId = 0 -- 93
							if stopToken.stopped then -- 93
								finishReject("request cancelled") -- 95
								return -- 96
							end -- 96
							if data ~= nil then -- 96
								finishResolve(data) -- 99
							else -- 99
								finishReject("failed to get http response") -- 101
							end -- 101
						end -- 92
					) -- 92
					if requestId == 0 then -- 92
						finishReject("failed to schedule http request") -- 105
					elseif stopToken.stopped then -- 105
						HttpClient:cancel(requestId) -- 107
						requestId = 0 -- 108
						finishReject("request cancelled") -- 109
					end -- 109
				else -- 109
					finishReject(err) -- 112
				end -- 112
			end)) -- 75
		end -- 48
	) -- 48
end -- 31
function ____exports.createSSEJSONParser(opts) -- 122
	local buffer = "" -- 127
	local eventDataLines = {} -- 128
	local function flushEventIfAny() -- 130
		if #eventDataLines == 0 then -- 130
			return -- 131
		end -- 131
		local dataPayload = table.concat(eventDataLines, "\n") -- 133
		eventDataLines = {} -- 134
		if dataPayload == "[DONE]" then -- 134
			local ____opt_0 = opts.onDone -- 134
			if ____opt_0 ~= nil then -- 134
				____opt_0(dataPayload) -- 137
			end -- 137
			return -- 138
		end -- 138
		local obj, err = json.decode(dataPayload) -- 141
		if err == nil then -- 141
			opts.onJSON(obj, dataPayload) -- 143
		else -- 143
			local ____opt_2 = opts.onError -- 143
			if ____opt_2 ~= nil then -- 143
				____opt_2(err, {raw = dataPayload}) -- 145
			end -- 145
		end -- 145
	end -- 130
	local function feed(chunk) -- 149
		buffer = buffer .. chunk -- 150
		while true do -- 150
			do -- 150
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 153
				if nl < 0 then -- 153
					break -- 154
				end -- 154
				local line = __TS__StringSlice(buffer, 0, nl) -- 156
				buffer = __TS__StringSlice(buffer, nl + 1) -- 157
				if __TS__StringEndsWith(line, "\r") then -- 157
					line = string.sub(line, 1, -2) -- 159
				end -- 159
				if line == "" then -- 159
					flushEventIfAny() -- 162
					goto __continue40 -- 163
				end -- 163
				if __TS__StringStartsWith(line, ":") then -- 163
					goto __continue40 -- 167
				end -- 167
				if __TS__StringStartsWith(line, "data:") then -- 167
					local v = string.sub(line, 6) -- 170
					if __TS__StringStartsWith(v, " ") then -- 170
						v = string.sub(v, 2) -- 171
					end -- 171
					eventDataLines[#eventDataLines + 1] = v -- 172
					goto __continue40 -- 173
				end -- 173
			end -- 173
			::__continue40:: -- 173
		end -- 173
	end -- 149
	local function ____end() -- 178
		if #buffer > 0 then -- 178
			local line = buffer -- 180
			buffer = "" -- 181
			if __TS__StringEndsWith(line, "\r") then -- 181
				line = string.sub(line, 1, -2) -- 182
			end -- 182
			if __TS__StringStartsWith(line, "data:") then -- 182
				local v = string.sub(line, 6) -- 185
				if __TS__StringStartsWith(v, " ") then -- 185
					v = string.sub(v, 2) -- 186
				end -- 186
				eventDataLines[#eventDataLines + 1] = v -- 187
			end -- 187
		end -- 187
		flushEventIfAny() -- 190
	end -- 178
	return {feed = feed, ["end"] = ____end} -- 193
end -- 122
local function getActiveLLMConfig() -- 265
	local rows = DB:query("select * from LLMConfig", true) -- 266
	local records = {} -- 267
	if rows and #rows > 1 then -- 267
		do -- 267
			local i = 1 -- 269
			while i < #rows do -- 269
				local record = {} -- 270
				do -- 270
					local c = 0 -- 271
					while c < #rows[i + 1] do -- 271
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 272
						c = c + 1 -- 271
					end -- 271
				end -- 271
				records[#records + 1] = record -- 274
				i = i + 1 -- 269
			end -- 269
		end -- 269
	end -- 269
	local config = __TS__ArrayFind( -- 277
		records, -- 277
		function(____, r) return r.active ~= 0 end -- 277
	) -- 277
	if not config then -- 277
		return {success = false, message = "no active LLM config"} -- 279
	end -- 279
	local url = config.url -- 279
	local model = config.model -- 279
	local api_key = config.api_key -- 279
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 279
		return {success = false, message = "got invalude LLM config"} -- 283
	end -- 283
	return {success = true, config = {url = url, model = model, api_key = api_key}} -- 285
end -- 265
____exports.callLLMStream = function(messages, options, event) -- 295
	local callEvent -- 296
	if event.id ~= nil then -- 296
		local id = event.id -- 298
		callEvent = { -- 299
			id = nil, -- 300
			onData = function(data) -- 301
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 302
				return event.stopToken.stopped -- 303
			end, -- 301
			onCancel = function(reason) -- 305
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 306
			end, -- 305
			onDone = function() -- 308
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 309
			end -- 308
		} -- 308
	else -- 308
		callEvent = event -- 313
	end -- 313
	local ____callEvent_4 = callEvent -- 315
	local onData = ____callEvent_4.onData -- 315
	local onDone = ____callEvent_4.onDone -- 315
	local ____callEvent_5 = callEvent -- 316
	local onCancel = ____callEvent_5.onCancel -- 316
	local configRes = getActiveLLMConfig() -- 317
	if not configRes.success then -- 317
		if onCancel then -- 317
			onCancel(configRes.message) -- 319
		end -- 319
		return {success = false, message = configRes.message} -- 320
	end -- 320
	local ____configRes_config_6 = configRes.config -- 322
	local url = ____configRes_config_6.url -- 322
	local model = ____configRes_config_6.model -- 322
	local api_key = ____configRes_config_6.api_key -- 322
	local stopLLM = false -- 323
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 324
		local result = onData(obj) -- 326
		if result then -- 326
			stopLLM = result -- 327
		end -- 327
	end}); -- 325
	(function() -- 330
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 330
			local ____try = __TS__AsyncAwaiter(function() -- 330
				local result = __TS__Await(postLLM( -- 332
					messages, -- 332
					url, -- 332
					api_key, -- 332
					model, -- 332
					options, -- 332
					true, -- 332
					function(data) -- 332
						if stopLLM then -- 332
							if onCancel then -- 332
								onCancel("LLM Stopped") -- 335
								onCancel = nil -- 336
							end -- 336
							return true -- 338
						end -- 338
						parser.feed(data) -- 340
						return false -- 341
					end, -- 332
					event.id ~= nil and event.stopToken or nil -- 342
				)) -- 342
				parser["end"]() -- 343
				if onDone then -- 343
					onDone(result) -- 345
				end -- 345
			end) -- 345
			__TS__Await(____try.catch( -- 331
				____try, -- 331
				function(____, e) -- 331
					stopLLM = true -- 348
					if onCancel then -- 348
						onCancel(tostring(e)) -- 350
						onCancel = nil -- 351
					end -- 351
				end -- 351
			)) -- 351
		end) -- 351
	end)() -- 330
	return {success = true} -- 355
end -- 295
function ____exports.callLLM(messages, options, stopToken) -- 358
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 358
		local configRes = getActiveLLMConfig() -- 363
		if not configRes.success then -- 363
			____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message) -- 365
			return ____awaiter_resolve(nil, {success = false, message = configRes.message}) -- 365
		end -- 365
		local ____configRes_config_7 = configRes.config -- 368
		local url = ____configRes_config_7.url -- 368
		local model = ____configRes_config_7.model -- 368
		local api_key = ____configRes_config_7.api_key -- 368
		____exports.Log( -- 369
			"Info", -- 369
			(((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages) -- 369
		) -- 369
		if stopToken and stopToken.stopped then -- 369
			local reason = stopToken.reason or "request cancelled" -- 371
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason) -- 372
			return ____awaiter_resolve(nil, {success = false, message = reason}) -- 372
		end -- 372
		local ____try = __TS__AsyncAwaiter(function() -- 372
			local raw = __TS__Await(postLLM( -- 376
				messages, -- 376
				url, -- 376
				api_key, -- 376
				model, -- 376
				options, -- 376
				false, -- 376
				nil, -- 376
				stopToken -- 376
			)) -- 376
			____exports.Log( -- 377
				"Info", -- 377
				"[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw) -- 377
			) -- 377
			local response, err = json.decode(raw) -- 378
			if err ~= nil or response == nil or type(response) ~= "table" then -- 378
				____exports.Log( -- 380
					"Error", -- 380
					"[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err) -- 380
				) -- 380
				return ____awaiter_resolve( -- 380
					nil, -- 380
					{ -- 381
						success = false, -- 382
						message = "invalid LLM response JSON: " .. tostring(err), -- 383
						raw = raw -- 384
					} -- 384
				) -- 384
			end -- 384
			local responseObj = response -- 387
			local choiceCount = responseObj.choices and #responseObj.choices or 0 -- 388
			____exports.Log( -- 389
				"Info", -- 389
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount) -- 389
			) -- 389
			return ____awaiter_resolve(nil, {success = true, response = responseObj}) -- 389
		end) -- 389
		__TS__Await(____try.catch( -- 375
			____try, -- 375
			function(____, e) -- 375
				if stopToken and stopToken.stopped then -- 375
					local reason = stopToken.reason or "request cancelled" -- 396
					____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason) -- 397
					return ____awaiter_resolve(nil, {success = false, message = reason}) -- 397
				end -- 397
				____exports.Log( -- 400
					"Error", -- 400
					"[Agent.Utils] callLLMOnce exception: " .. tostring(e) -- 400
				) -- 400
				return ____awaiter_resolve( -- 400
					nil, -- 400
					{ -- 401
						success = false, -- 401
						message = tostring(e) -- 401
					} -- 401
				) -- 401
			end -- 401
		)) -- 401
	end) -- 401
end -- 358
return ____exports -- 358