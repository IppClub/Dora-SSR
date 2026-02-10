-- [ts]: Utils.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
function ____exports.createSSEJSONParser(opts) -- 8
	local buffer = "" -- 13
	local eventDataLines = {} -- 14
	local function flushEventIfAny() -- 16
		if #eventDataLines == 0 then -- 16
			return -- 17
		end -- 17
		local dataPayload = table.concat(eventDataLines, "\n") -- 20
		eventDataLines = {} -- 21
		if dataPayload == "[DONE]" then -- 21
			local ____opt_0 = opts.onDone -- 21
			if ____opt_0 ~= nil then -- 21
				____opt_0(dataPayload) -- 25
			end -- 25
			return -- 26
		end -- 26
		local obj, err = json.decode(dataPayload) -- 30
		if err == nil then -- 30
			opts.onJSON(obj, dataPayload) -- 32
		else -- 32
			local ____opt_2 = opts.onError -- 32
			if ____opt_2 ~= nil then -- 32
				____opt_2(err, {raw = dataPayload}) -- 34
			end -- 34
		end -- 34
	end -- 16
	--- 你的底层每收到一个 string chunk 就调用 feed(chunk)
	local function feed(chunk) -- 41
		buffer = buffer .. chunk -- 42
		while true do -- 42
			do -- 42
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1 -- 46
				if nl < 0 then -- 46
					break -- 47
				end -- 47
				local line = __TS__StringSlice(buffer, 0, nl) -- 49
				buffer = __TS__StringSlice(buffer, nl + 1) -- 50
				if __TS__StringEndsWith(line, "\r") then -- 50
					line = string.sub(line, 1, -2) -- 53
				end -- 53
				if line == "" then -- 53
					flushEventIfAny() -- 57
					goto __continue9 -- 58
				end -- 58
				if __TS__StringStartsWith(line, ":") then -- 58
					goto __continue9 -- 62
				end -- 62
				if __TS__StringStartsWith(line, "data:") then -- 62
					local v = string.sub(line, 6) -- 67
					if __TS__StringStartsWith(v, " ") then -- 67
						v = string.sub(v, 2) -- 68
					end -- 68
					eventDataLines[#eventDataLines + 1] = v -- 69
					goto __continue9 -- 70
				end -- 70
			end -- 70
			::__continue9:: -- 70
		end -- 70
	end -- 41
	--- 流结束时可调用，避免最后一个事件没有以空行收尾导致丢失
	local function ____end() -- 81
		if #buffer > 0 then -- 81
			local line = buffer -- 85
			buffer = "" -- 86
			if __TS__StringEndsWith(line, "\r") then -- 86
				line = string.sub(line, 1, -2) -- 87
			end -- 87
			if __TS__StringStartsWith(line, "data:") then -- 87
				local v = string.sub(line, 6) -- 90
				if __TS__StringStartsWith(v, " ") then -- 90
					v = string.sub(v, 2) -- 91
				end -- 91
				eventDataLines[#eventDataLines + 1] = v -- 92
			end -- 92
		end -- 92
		flushEventIfAny() -- 95
	end -- 81
	return {feed = feed, ["end"] = ____end} -- 98
end -- 8
return ____exports -- 8