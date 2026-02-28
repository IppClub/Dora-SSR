-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
local Node = ____Dora.Node -- 2
local function postLLM(messages, url, apiKey, model, options, receiver) -- 9
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = true}) -- 10
	return __TS__New( -- 16
		__TS__Promise, -- 16
		function(____, resolve, reject) -- 16
			local node = Node() -- 17
			local quit = false -- 18
			node:onCleanup(function() -- 19
				quit = true -- 20
			end) -- 19
			node:once(function() -- 22
				local jsonStr, err = json.encode(data) -- 23
				if jsonStr ~= nil then -- 23
					local res = HttpClient:postAsync( -- 25
						url, -- 25
						{"Authorization: Bearer " .. apiKey}, -- 25
						jsonStr, -- 27
						10, -- 27
						function(data) -- 27
							if quit then -- 27
								return true -- 29
							end -- 29
							return receiver(data) -- 31
						end -- 27
					) -- 27
					if res then -- 27
						resolve(nil, res) -- 34
					else -- 34
						reject(nil, "failed to get http response") -- 36
					end -- 36
				else -- 36
					reject(nil, err) -- 39
				end -- 39
			end) -- 22
		end -- 16
	) -- 16
end -- 9
function ____exports.createSSEJSONParser(opts) -- 49
	local buffer = "" -- 54
	local eventDataLines = {} -- 55
	local function flushEventIfAny() -- 57
		if #eventDataLines == 0 then -- 57
			return -- 58
		end -- 58
		local dataPayload = table.concat(eventDataLines, "\n") -- 60
		eventDataLines = {} -- 61
		if dataPayload == "[DONE]" then -- 61
			local ____opt_0 = opts.onDone -- 61
			if ____opt_0 ~= nil then -- 61
				____opt_0(dataPayload) -- 64
			end -- 64
			return -- 65
		end -- 65
		local obj, err = json.decode(dataPayload) -- 68
		if err == nil then -- 68
			opts.onJSON(obj, dataPayload) -- 70
		else -- 70
			local ____opt_2 = opts.onError -- 70
			if ____opt_2 ~= nil then -- 70
				____opt_2(err, {raw = dataPayload}) -- 72
			end -- 72
		end -- 72
	end -- 57
	local function feed(chunk) -- 76
		buffer = buffer .. chunk -- 77
		while true do -- 77
			do -- 77
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 80
				if nl < 0 then -- 80
					break -- 81
				end -- 81
				local line = __TS__StringSlice(buffer, 0, nl) -- 83
				buffer = __TS__StringSlice(buffer, nl + 1) -- 84
				if __TS__StringEndsWith(line, "\r") then -- 84
					line = string.sub(line, 1, -2) -- 86
				end -- 86
				if line == "" then -- 86
					flushEventIfAny() -- 89
					goto __continue19 -- 90
				end -- 90
				if __TS__StringStartsWith(line, ":") then -- 90
					goto __continue19 -- 94
				end -- 94
				if __TS__StringStartsWith(line, "data:") then -- 94
					local v = string.sub(line, 6) -- 97
					if __TS__StringStartsWith(v, " ") then -- 97
						v = string.sub(v, 2) -- 98
					end -- 98
					eventDataLines[#eventDataLines + 1] = v -- 99
					goto __continue19 -- 100
				end -- 100
			end -- 100
			::__continue19:: -- 100
		end -- 100
	end -- 76
	local function ____end() -- 105
		if #buffer > 0 then -- 105
			local line = buffer -- 107
			buffer = "" -- 108
			if __TS__StringEndsWith(line, "\r") then -- 108
				line = string.sub(line, 1, -2) -- 109
			end -- 109
			if __TS__StringStartsWith(line, "data:") then -- 109
				local v = string.sub(line, 6) -- 112
				if __TS__StringStartsWith(v, " ") then -- 112
					v = string.sub(v, 2) -- 113
				end -- 113
				eventDataLines[#eventDataLines + 1] = v -- 114
			end -- 114
		end -- 114
		flushEventIfAny() -- 117
	end -- 105
	return {feed = feed, ["end"] = ____end} -- 120
end -- 49
____exports.callLLM = function(messages, options, event) -- 154
	local callEvent -- 155
	if event.id ~= nil then -- 155
		local id = event.id -- 157
		callEvent = { -- 158
			id = nil, -- 159
			onData = function(data) -- 160
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 161
				return event.stopToken -- 162
			end, -- 160
			onCancel = function(reason) -- 164
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 165
			end, -- 164
			onDone = function() -- 167
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 168
			end -- 167
		} -- 167
	else -- 167
		callEvent = event -- 172
	end -- 172
	local ____callEvent_4 = callEvent -- 174
	local onData = ____callEvent_4.onData -- 174
	local onDone = ____callEvent_4.onDone -- 174
	local ____callEvent_5 = callEvent -- 175
	local onCancel = ____callEvent_5.onCancel -- 175
	local rows = DB:query("select * from LLMConfig", true) -- 176
	local records = {} -- 177
	if rows and #rows > 1 then -- 177
		do -- 177
			local i = 1 -- 179
			while i < #rows do -- 179
				local record = {} -- 180
				do -- 180
					local c = 0 -- 181
					while c < #rows[i + 1] do -- 181
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 182
						c = c + 1 -- 181
					end -- 181
				end -- 181
				records[#records + 1] = record -- 184
				i = i + 1 -- 179
			end -- 179
		end -- 179
	end -- 179
	local config = __TS__ArrayFind( -- 187
		records, -- 187
		function(____, r) return r.active ~= 0 end -- 187
	) -- 187
	if not config then -- 187
		if onCancel then -- 187
			onCancel("no active LLM config") -- 189
		end -- 189
		return {success = false, message = "no active LLM config"} -- 190
	end -- 190
	local url = config.url -- 190
	local model = config.model -- 190
	local api_key = config.api_key -- 190
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 190
		if onCancel then -- 190
			onCancel("got invalude LLM config") -- 194
		end -- 194
		return {success = false, message = "got invalude LLM config"} -- 195
	end -- 195
	local stopLLM = false -- 197
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 198
		local result = onData(obj) -- 200
		if result then -- 200
			stopLLM = result -- 201
		end -- 201
	end}); -- 199
	(function() -- 204
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 204
			local ____try = __TS__AsyncAwaiter(function() -- 204
				local result = __TS__Await(postLLM( -- 206
					messages, -- 206
					url, -- 206
					api_key, -- 206
					model, -- 206
					options, -- 206
					function(data) -- 206
						if stopLLM then -- 206
							if onCancel then -- 206
								onCancel("LLM Stopped") -- 209
								onCancel = nil -- 210
							end -- 210
							return true -- 212
						end -- 212
						parser.feed(data) -- 214
						return false -- 215
					end -- 206
				)) -- 206
				parser["end"]() -- 217
				if onDone then -- 217
					onDone(result) -- 219
				end -- 219
			end) -- 219
			__TS__Await(____try.catch( -- 205
				____try, -- 205
				function(____, e) -- 205
					stopLLM = true -- 222
					if onCancel then -- 222
						onCancel(tostring(e)) -- 224
						onCancel = nil -- 225
					end -- 225
				end -- 225
			)) -- 225
		end) -- 225
	end)() -- 204
	return {success = true} -- 229
end -- 154
return ____exports -- 154