-- [ts]: FeedModel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
--- ASCII project names use A-Z; Chinese and every other leading character use #.
____exports.getFeedProjectGroup = function(title) -- 23
	local initial = (string.match(title, "^%s*([A-Za-z])")) -- 24
	return initial == nil and "#" or string.upper(initial) -- 25
end -- 23
____exports.groupFeedProjects = function(entries) -- 28
	local sorted = {table.unpack(entries)} -- 29
	__TS__ArraySort( -- 30
		sorted, -- 30
		function(____, a, b) -- 30
			local aGroup = ____exports.getFeedProjectGroup(a.title) -- 31
			local bGroup = ____exports.getFeedProjectGroup(b.title) -- 32
			if aGroup ~= bGroup then -- 32
				if aGroup == "#" then -- 32
					return 1 -- 34
				end -- 34
				if bGroup == "#" then -- 34
					return -1 -- 35
				end -- 35
				return aGroup < bGroup and -1 or 1 -- 36
			end -- 36
			local aTitle = string.lower(a.title) -- 38
			local bTitle = string.lower(b.title) -- 39
			return aTitle == bTitle and 0 or (aTitle < bTitle and -1 or 1) -- 40
		end -- 30
	) -- 30
	local groups = {} -- 42
	for ____, entry in ipairs(sorted) do -- 43
		local key = ____exports.getFeedProjectGroup(entry.title) -- 44
		local group = groups[#groups] -- 45
		if (group and group.key) ~= key then -- 45
			group = {key = key, entries = {}} -- 47
			groups[#groups + 1] = group -- 48
		end -- 48
		local ____group_entries_2 = group.entries -- 48
		____group_entries_2[#____group_entries_2 + 1] = entry -- 50
	end -- 50
	return groups -- 52
end -- 28
____exports.normalizeFeedIndex = function(index, count) -- 55
	if count <= 0 then -- 55
		return 0 -- 56
	end -- 56
	return math.max( -- 57
		0, -- 57
		math.min( -- 57
			math.floor(index), -- 57
			count - 1 -- 57
		) -- 57
	) -- 57
end -- 55
function ____exports.resolveFeedLocation(____local, discover, target) -- 60
	if target then -- 60
		local preferred = target.kind == "discover" and discover or ____local -- 62
		local other = target.kind == "discover" and ____local or discover -- 63
		local function match(items) -- 64
			local index = target.fileName and __TS__ArrayFindIndex( -- 66
				items, -- 66
				function(____, item) return item.fileName == target.fileName end -- 66
			) or -1 -- 66
			if index < 0 and target.workDir then -- 66
				index = __TS__ArrayFindIndex( -- 67
					items, -- 67
					function(____, item) return item.workDir == target.workDir end -- 67
				) -- 67
			end -- 67
			if index < 0 then -- 67
				index = __TS__ArrayFindIndex( -- 68
					items, -- 68
					function(____, item) return item.id == target.id and item.kind == target.kind end -- 68
				) -- 68
			end -- 68
			return index -- 69
		end -- 64
		local index = match(preferred) -- 71
		if index >= 0 then -- 71
			return {tab = target.kind, index = index} -- 72
		end -- 72
		local alternate = match(other) -- 73
		if alternate >= 0 then -- 73
			return {tab = target.kind == "discover" and "local" or "discover", index = alternate} -- 74
		end -- 74
	end -- 74
	return {tab = #____local > 0 and "local" or "discover", index = 0} -- 76
end -- 60
____exports.getReusableCardIndices = function(index, count) -- 79
	if count <= 0 then -- 79
		return {} -- 80
	end -- 80
	local current = ____exports.normalizeFeedIndex(index, count) -- 81
	local result = {} -- 82
	if current > 0 then -- 82
		result[#result + 1] = current - 1 -- 83
	end -- 83
	result[#result + 1] = current -- 84
	if current + 1 < count then -- 84
		result[#result + 1] = current + 1 -- 85
	end -- 85
	return result -- 86
end -- 79
____exports.resolveFeedGesture = function(dx, dy, width, height, controlCaptured) -- 89
	if controlCaptured == nil then -- 89
		controlCaptured = false -- 94
	end -- 94
	if controlCaptured then -- 94
		return "none" -- 96
	end -- 96
	local absX = math.abs(dx) -- 97
	local absY = math.abs(dy) -- 98
	if absX < 18 and absY < 18 then -- 98
		return "none" -- 99
	end -- 99
	if absX > absY * 1.2 then -- 99
		if absX < math.max(64, width * 0.18) then -- 99
			return "none" -- 101
		end -- 101
		return dx > 0 and "remix" or "play" -- 102
	end -- 102
	if absY < math.max(72, height * 0.14) then -- 102
		return "none" -- 104
	end -- 104
	return dy > 0 and "next" or "previous" -- 105
end -- 89
____exports.stableCoverColor = function(id) -- 108
	local hash = 17 -- 109
	do -- 109
		local i = 0 -- 110
		while i < #id do -- 110
			hash = (hash * 31 + __TS__StringCharCodeAt(id, i)) % 9973 -- 110
			i = i + 1 -- 110
		end -- 110
	end -- 110
	local palette = { -- 111
		4280299593, -- 111
		4280761397, -- 111
		4282001736, -- 111
		4282790184, -- 111
		4280695880, -- 111
		4282332480 -- 111
	} -- 111
	return palette[hash % #palette + 1] -- 112
end -- 108
____exports.getCoverScales = function(sourceWidth, sourceHeight, targetWidth, targetHeight) -- 115
	if sourceWidth <= 0 or sourceHeight <= 0 or targetWidth <= 0 or targetHeight <= 0 then -- 115
		return {contain = 1, cover = 1} -- 117
	end -- 117
	return { -- 119
		contain = math.min(targetWidth / sourceWidth, targetHeight / sourceHeight), -- 120
		cover = math.max(targetWidth / sourceWidth, targetHeight / sourceHeight) -- 121
	} -- 121
end -- 115
____exports.resolveDiscoverRefreshTab = function(currentTab, userSelectedTab, previousDiscoverCount, refreshedDiscoverCount, localCount) -- 125
	if localCount == nil then -- 125
		localCount = 0 -- 130
	end -- 130
	return not userSelectedTab and localCount == 0 and previousDiscoverCount == 0 and refreshedDiscoverCount > 0 and "discover" or currentTab -- 131
end -- 125
return ____exports -- 125