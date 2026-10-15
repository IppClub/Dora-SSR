-- [ts]: RepeatedOutput.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
function ____exports.decisionOutputKey(message) -- 8
	local parts = {message.content or "", message.reasoning_content or ""} -- 9
	for ____, call in ipairs(message.tool_calls or ({})) do -- 10
		local ____opt_0 = call["function"] -- 10
		local ____temp_4 = ____opt_0 and ____opt_0.name or "" -- 11
		local ____opt_2 = call["function"] -- 11
		__TS__ArrayPush(parts, ____temp_4, ____opt_2 and ____opt_2.arguments or "") -- 11
	end -- 11
	return table.concat( -- 14
		__TS__ArrayMap( -- 14
			parts, -- 14
			function(____, part) return (tostring(#part) .. ":") .. part end -- 14
		), -- 14
		"" -- 14
	) -- 14
end -- 8
--- One recovery per identical output in this task; explicit continuation starts fresh.
____exports.RepeatedOutputRecovery = __TS__Class() -- 18
local RepeatedOutputRecovery = ____exports.RepeatedOutputRecovery -- 18
RepeatedOutputRecovery.name = "RepeatedOutputRecovery" -- 18
function RepeatedOutputRecovery.prototype.____constructor(self) -- 18
	self.recovered = __TS__New(Set) -- 20
end -- 18
function RepeatedOutputRecovery.prototype.observe(self, message) -- 22
	local key = ____exports.decisionOutputKey(message) -- 23
	local repeated = key == self.previous -- 24
	self.previous = key -- 25
	if not repeated then -- 25
		return "accept" -- 26
	end -- 26
	if self.recovered:has(key) then -- 26
		return "pause" -- 27
	end -- 27
	self.recovered:add(key) -- 28
	return "compact" -- 29
end -- 22
return ____exports -- 22