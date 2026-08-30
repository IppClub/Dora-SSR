-- [ts]: RemixHistory.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
____exports.REMIX_HISTORY_ROUNDS = 10 -- 3
function ____exports.remixHistory(detail) -- 7
	if not detail.success then -- 7
		return {messages = {}, steps = {}, hasEarlierMessages = false} -- 8
	end -- 8
	local start = 0 -- 9
	local rounds = 0 -- 9
	do -- 9
		local i = #detail.messages - 1 -- 10
		while i >= 0 do -- 10
			do -- 10
				if detail.messages[i + 1].role ~= "user" then -- 10
					goto __continue5 -- 11
				end -- 11
				rounds = rounds + 1 -- 12
				if rounds == ____exports.REMIX_HISTORY_ROUNDS then -- 12
					start = i -- 13
				end -- 13
				if rounds > ____exports.REMIX_HISTORY_ROUNDS then -- 13
					break -- 14
				end -- 14
			end -- 14
			::__continue5:: -- 14
			i = i - 1 -- 10
		end -- 10
	end -- 10
	if rounds <= ____exports.REMIX_HISTORY_ROUNDS then -- 10
		start = 0 -- 16
	end -- 16
	return { -- 17
		messages = __TS__ArraySlice(detail.messages, start), -- 18
		steps = __TS__ArrayFilter( -- 19
			detail.steps, -- 19
			function(____, s) return s.taskId == detail.session.currentTaskId end -- 19
		), -- 19
		hasEarlierMessages = detail.hasEarlierMessages == true or start > 0 -- 20
	} -- 20
end -- 7
return ____exports -- 7