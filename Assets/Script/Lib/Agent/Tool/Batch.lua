-- [ts]: Batch.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
function ____exports.cloneAgentToolParams(value) -- 15
	local function clone(item) -- 16
		if item == nil then -- 16
			return item -- 17
		end -- 17
		if __TS__ArrayIsArray(item) then -- 17
			return __TS__ArrayMap( -- 18
				item, -- 18
				function(____, child) return clone(child) end -- 18
			) -- 18
		end -- 18
		if type(item) == "table" then -- 18
			local output = {} -- 20
			for key in pairs(item) do -- 21
				output[key] = clone(item[key]) -- 21
			end -- 21
			return output -- 22
		end -- 22
		return item -- 24
	end -- 16
	return clone(value) -- 26
end -- 15
function ____exports.areAgentToolParamsEqual(left, right) -- 29
	if left == right then -- 29
		return true -- 30
	end -- 30
	if left == nil or right == nil then -- 30
		return false -- 31
	end -- 31
	if __TS__ArrayIsArray(left) or __TS__ArrayIsArray(right) then -- 31
		if not __TS__ArrayIsArray(left) or not __TS__ArrayIsArray(right) or #left ~= #right then -- 31
			return false -- 33
		end -- 33
		do -- 33
			local i = 0 -- 34
			while i < #left do -- 34
				if not ____exports.areAgentToolParamsEqual(left[i + 1], right[i + 1]) then -- 34
					return false -- 35
				end -- 35
				i = i + 1 -- 34
			end -- 34
		end -- 34
		return true -- 37
	end -- 37
	if type(left) == "table" and type(right) == "table" then -- 37
		local leftCount = 0 -- 40
		for key in pairs(left) do -- 41
			leftCount = leftCount + 1 -- 42
			if not ____exports.areAgentToolParamsEqual(left[key], right[key]) then -- 42
				return false -- 43
			end -- 43
		end -- 43
		local rightCount = 0 -- 45
		for _key in pairs(right) do -- 46
			rightCount = rightCount + 1 -- 46
		end -- 46
		return leftCount == rightCount -- 47
	end -- 47
	return false -- 49
end -- 29
function ____exports.partitionAgentToolCalls(actions, isParallelSafe) -- 52
	local batches = {} -- 56
	do -- 56
		local i = 0 -- 57
		while i < #actions do -- 57
			local action = actions[i + 1] -- 58
			local isSafe = isParallelSafe(action.tool) -- 59
			local last = #batches > 0 and batches[#batches] or nil -- 60
			if isSafe and (last and last.isConcurrencySafe) == true then -- 60
				local ____last_actions_2 = last.actions -- 60
				____last_actions_2[#____last_actions_2 + 1] = action -- 61
			else -- 61
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 62
			end -- 62
			i = i + 1 -- 57
		end -- 57
	end -- 57
	return batches -- 64
end -- 52
return ____exports -- 52