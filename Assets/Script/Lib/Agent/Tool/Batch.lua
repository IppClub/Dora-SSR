-- [ts]: Batch.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
function ____exports.cloneAgentToolParams(value) -- 21
	local function clone(item) -- 22
		if item == nil then -- 22
			return item -- 23
		end -- 23
		if __TS__ArrayIsArray(item) then -- 23
			return __TS__ArrayMap( -- 24
				item, -- 24
				function(____, child) return clone(child) end -- 24
			) -- 24
		end -- 24
		if type(item) == "table" then -- 24
			local output = {} -- 26
			for key in pairs(item) do -- 27
				output[key] = clone(item[key]) -- 27
			end -- 27
			return output -- 28
		end -- 28
		return item -- 30
	end -- 22
	return clone(value) -- 32
end -- 21
function ____exports.areAgentToolParamsEqual(left, right) -- 35
	if left == right then -- 35
		return true -- 36
	end -- 36
	if left == nil or right == nil then -- 36
		return false -- 37
	end -- 37
	if __TS__ArrayIsArray(left) or __TS__ArrayIsArray(right) then -- 37
		if not __TS__ArrayIsArray(left) or not __TS__ArrayIsArray(right) or #left ~= #right then -- 37
			return false -- 39
		end -- 39
		do -- 39
			local i = 0 -- 40
			while i < #left do -- 40
				if not ____exports.areAgentToolParamsEqual(left[i + 1], right[i + 1]) then -- 40
					return false -- 41
				end -- 41
				i = i + 1 -- 40
			end -- 40
		end -- 40
		return true -- 43
	end -- 43
	if type(left) == "table" and type(right) == "table" then -- 43
		local leftCount = 0 -- 46
		for key in pairs(left) do -- 47
			leftCount = leftCount + 1 -- 48
			if not ____exports.areAgentToolParamsEqual(left[key], right[key]) then -- 48
				return false -- 49
			end -- 49
		end -- 49
		local rightCount = 0 -- 51
		for _key in pairs(right) do -- 52
			rightCount = rightCount + 1 -- 52
		end -- 52
		return leftCount == rightCount -- 53
	end -- 53
	return false -- 55
end -- 35
local function getReadBatchItems(params) -- 58
	if not __TS__ArrayIsArray(params.reads) then -- 58
		return nil -- 59
	end -- 59
	return __TS__ArrayMap( -- 60
		params.reads, -- 60
		function(____, item) return ____exports.cloneAgentToolParams(item) end -- 60
	) -- 60
end -- 58
local function getBuildBatchPaths(params) -- 63
	return __TS__ArrayIsArray(params.paths) and __TS__ArraySlice(params.paths) or nil -- 64
end -- 63
--- Normalize consecutive compatible calls from one model response into the
-- existing batch form. The first call id is retained because history records
-- the normalized assistant message, while the raw provider response remains
-- available in the per-step debug output.
function ____exports.coalesceCompatibleAgentToolCalls(actions) -- 73
	local output = {} -- 74
	local index = 0 -- 75
	while index < #actions do -- 75
		do -- 75
			local first = actions[index + 1] -- 77
			if first.tool ~= "read_file" and first.tool ~= "build" then -- 77
				output[#output + 1] = first -- 79
				index = index + 1 -- 80
				goto __continue29 -- 81
			end -- 81
			local ____end = index -- 83
			while ____end + 1 < #actions and actions[____end + 1 + 1].tool == first.tool do -- 83
				____end = ____end + 1 -- 84
			end -- 84
			if ____end == index then -- 84
				output[#output + 1] = first -- 86
				index = index + 1 -- 87
				goto __continue29 -- 88
			end -- 88
			if first.tool == "read_file" then -- 88
				local reads = {} -- 91
				local compatible = true -- 92
				do -- 92
					local i = index -- 93
					while i <= ____end do -- 93
						local items = getReadBatchItems(actions[i + 1].params) -- 94
						if items == nil then -- 94
							compatible = false -- 95
							break -- 95
						end -- 95
						__TS__ArrayPushArray(reads, items) -- 96
						i = i + 1 -- 93
					end -- 93
				end -- 93
				if compatible then -- 93
					output[#output + 1] = __TS__ObjectAssign({}, first, {params = {reads = reads}}) -- 99
					index = ____end + 1 -- 100
					goto __continue29 -- 101
				end -- 101
			else -- 101
				local paths = {} -- 104
				local compatible = true -- 105
				do -- 105
					local i = index -- 106
					while i <= ____end do -- 106
						local items = getBuildBatchPaths(actions[i + 1].params) -- 107
						if items == nil then -- 107
							compatible = false -- 108
							break -- 108
						end -- 108
						__TS__ArrayPushArray(paths, items) -- 109
						i = i + 1 -- 106
					end -- 106
				end -- 106
				if compatible then -- 106
					output[#output + 1] = __TS__ObjectAssign({}, first, {params = {paths = paths}}) -- 112
					index = ____end + 1 -- 113
					goto __continue29 -- 114
				end -- 114
			end -- 114
			do -- 114
				local i = index -- 117
				while i <= ____end do -- 117
					output[#output + 1] = actions[i + 1] -- 117
					i = i + 1 -- 117
				end -- 117
			end -- 117
			index = ____end + 1 -- 118
		end -- 118
		::__continue29:: -- 118
	end -- 118
	return output -- 120
end -- 73
function ____exports.partitionAgentToolCalls(actions, isParallelSafe) -- 123
	local batches = {} -- 127
	do -- 127
		local i = 0 -- 128
		while i < #actions do -- 128
			local action = actions[i + 1] -- 129
			local isSafe = isParallelSafe(action.tool) -- 130
			local last = #batches > 0 and batches[#batches] or nil -- 131
			if isSafe and (last and last.isConcurrencySafe) == true then -- 131
				local ____last_actions_2 = last.actions -- 131
				____last_actions_2[#____last_actions_2 + 1] = action -- 132
			else -- 132
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 133
			end -- 133
			i = i + 1 -- 128
		end -- 128
	end -- 128
	return batches -- 135
end -- 123
return ____exports -- 123