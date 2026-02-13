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
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local HttpClient = ____Dora.HttpClient -- 2
local DB = ____Dora.DB -- 2
local emit = ____Dora.emit -- 2
local function postLLM(messages, url, apiKey, model, options, receiver) -- 9
	local data = __TS__ObjectAssign({}, options, {model = model, messages = messages, stream = true}) -- 10
	return __TS__New( -- 16
		__TS__Promise, -- 16
		function(____, resolve, reject) -- 16
			Director.systemScheduler:schedule(once(function() -- 17
				local jsonStr, err = json.encode(data) -- 18
				if jsonStr ~= nil then -- 18
					local res = HttpClient:postAsync( -- 20
						url, -- 20
						{"Authorization: Bearer " .. apiKey}, -- 20
						jsonStr, -- 22
						10, -- 22
						receiver -- 22
					) -- 22
					if res then -- 22
						resolve(nil, res) -- 24
					else -- 24
						reject(nil, "failed to get http response") -- 26
					end -- 26
				else -- 26
					reject(nil, err) -- 29
				end -- 29
			end)) -- 17
		end -- 16
	) -- 16
end -- 9
function ____exports.createSSEJSONParser(opts) -- 39
	local buffer = "" -- 44
	local eventDataLines = {} -- 45
	local function flushEventIfAny() -- 47
		if #eventDataLines == 0 then -- 47
			return -- 48
		end -- 48
		local dataPayload = table.concat(eventDataLines, "\n") -- 50
		eventDataLines = {} -- 51
		if dataPayload == "[DONE]" then -- 51
			local ____opt_0 = opts.onDone -- 51
			if ____opt_0 ~= nil then -- 51
				____opt_0(dataPayload) -- 54
			end -- 54
			return -- 55
		end -- 55
		local obj, err = json.decode(dataPayload) -- 58
		if err == nil then -- 58
			opts.onJSON(obj, dataPayload) -- 60
		else -- 60
			local ____opt_2 = opts.onError -- 60
			if ____opt_2 ~= nil then -- 60
				____opt_2(err, {raw = dataPayload}) -- 62
			end -- 62
		end -- 62
	end -- 47
	local function feed(chunk) -- 66
		buffer = buffer .. chunk -- 67
		while true do -- 67
			do -- 67
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 70
				if nl < 0 then -- 70
					break -- 71
				end -- 71
				local line = __TS__StringSlice(buffer, 0, nl) -- 73
				buffer = __TS__StringSlice(buffer, nl + 1) -- 74
				if __TS__StringEndsWith(line, "\r") then -- 74
					line = string.sub(line, 1, -2) -- 76
				end -- 76
				if line == "" then -- 76
					flushEventIfAny() -- 79
					goto __continue16 -- 80
				end -- 80
				if __TS__StringStartsWith(line, ":") then -- 80
					goto __continue16 -- 84
				end -- 84
				if __TS__StringStartsWith(line, "data:") then -- 84
					local v = string.sub(line, 6) -- 87
					if __TS__StringStartsWith(v, " ") then -- 87
						v = string.sub(v, 2) -- 88
					end -- 88
					eventDataLines[#eventDataLines + 1] = v -- 89
					goto __continue16 -- 90
				end -- 90
			end -- 90
			::__continue16:: -- 90
		end -- 90
	end -- 66
	local function ____end() -- 95
		if #buffer > 0 then -- 95
			local line = buffer -- 97
			buffer = "" -- 98
			if __TS__StringEndsWith(line, "\r") then -- 98
				line = string.sub(line, 1, -2) -- 99
			end -- 99
			if __TS__StringStartsWith(line, "data:") then -- 99
				local v = string.sub(line, 6) -- 102
				if __TS__StringStartsWith(v, " ") then -- 102
					v = string.sub(v, 2) -- 103
				end -- 103
				eventDataLines[#eventDataLines + 1] = v -- 104
			end -- 104
		end -- 104
		flushEventIfAny() -- 107
	end -- 95
	return {feed = feed, ["end"] = ____end} -- 110
end -- 39
____exports.callLLM = function(messages, options, event) -- 144
	local callEvent -- 145
	if event.id ~= nil then -- 145
		local id = event.id -- 147
		callEvent = { -- 148
			id = nil, -- 149
			onData = function(data) -- 150
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data}) -- 151
				return event.stopToken -- 152
			end, -- 150
			onCancel = function(reason) -- 154
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason}) -- 155
			end, -- 154
			onDone = function() -- 157
				emit("AppWS", "Send", {name = "LLMDone", id = id}) -- 158
			end -- 157
		} -- 157
	else -- 157
		callEvent = event -- 162
	end -- 162
	local ____callEvent_4 = callEvent -- 164
	local onData = ____callEvent_4.onData -- 164
	local onDone = ____callEvent_4.onDone -- 164
	local ____callEvent_5 = callEvent -- 165
	local onCancel = ____callEvent_5.onCancel -- 165
	local rows = DB:query("select * from LLMConfig", true) -- 166
	local records = {} -- 167
	if rows and #rows > 1 then -- 167
		do -- 167
			local i = 1 -- 169
			while i < #rows do -- 169
				local record = {} -- 170
				do -- 170
					local c = 0 -- 171
					while c < #rows[i + 1] do -- 171
						record[rows[1][c + 1]] = rows[i + 1][c + 1] -- 172
						c = c + 1 -- 171
					end -- 171
				end -- 171
				records[#records + 1] = record -- 174
				i = i + 1 -- 169
			end -- 169
		end -- 169
	end -- 169
	local config = __TS__ArrayFind( -- 177
		records, -- 177
		function(____, r) return r.active ~= 0 end -- 177
	) -- 177
	if not config then -- 177
		return {success = false, message = "no active LLM config"} -- 178
	end -- 178
	local url = config.url -- 178
	local model = config.model -- 178
	local api_key = config.api_key -- 178
	if type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then -- 178
		return {success = false, message = "got invalude LLM config"} -- 181
	end -- 181
	local stopLLM = false -- 183
	local parser = ____exports.createSSEJSONParser({onJSON = function(obj) -- 184
		local result = onData(obj) -- 186
		if result then -- 186
			stopLLM = result -- 187
		end -- 187
	end}); -- 185
	(function() -- 190
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 190
			local ____try = __TS__AsyncAwaiter(function() -- 190
				local result = __TS__Await(postLLM( -- 192
					messages, -- 192
					url, -- 192
					api_key, -- 192
					model, -- 192
					options, -- 192
					function(data) -- 192
						if stopLLM then -- 192
							if onCancel then -- 192
								onCancel("LLM Stopped") -- 195
								onCancel = nil -- 196
							end -- 196
							return true -- 198
						end -- 198
						parser.feed(data) -- 200
						return false -- 201
					end -- 192
				)) -- 192
				parser["end"]() -- 203
				if onDone then -- 203
					onDone(result) -- 205
				end -- 205
			end) -- 205
			__TS__Await(____try.catch( -- 191
				____try, -- 191
				function(____, e) -- 191
					stopLLM = true -- 208
					if onCancel then -- 208
						onCancel(tostring(e)) -- 210
						onCancel = nil -- 211
					end -- 211
				end -- 211
			)) -- 211
		end) -- 211
	end)() -- 190
	return {success = true} -- 215
end -- 144
return ____exports -- 144