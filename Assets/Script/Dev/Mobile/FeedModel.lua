-- [ts]: FeedModel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
--- ASCII project names use A-Z; Chinese and every other leading character use #.
____exports.getFeedProjectGroup = function(title) -- 21
	local initial = (string.match(title, "^%s*([A-Za-z])")) -- 22
	return initial == nil and "#" or string.upper(initial) -- 23
end -- 21
____exports.groupFeedProjects = function(entries) -- 26
	local sorted = {table.unpack(entries)} -- 27
	__TS__ArraySort( -- 28
		sorted, -- 28
		function(____, a, b) -- 28
			local aGroup = ____exports.getFeedProjectGroup(a.title) -- 29
			local bGroup = ____exports.getFeedProjectGroup(b.title) -- 30
			if aGroup ~= bGroup then -- 30
				if aGroup == "#" then -- 30
					return 1 -- 32
				end -- 32
				if bGroup == "#" then -- 32
					return -1 -- 33
				end -- 33
				return aGroup < bGroup and -1 or 1 -- 34
			end -- 34
			local aTitle = string.lower(a.title) -- 36
			local bTitle = string.lower(b.title) -- 37
			return aTitle == bTitle and 0 or (aTitle < bTitle and -1 or 1) -- 38
		end -- 28
	) -- 28
	local groups = {} -- 40
	for ____, entry in ipairs(sorted) do -- 41
		local key = ____exports.getFeedProjectGroup(entry.title) -- 42
		local group = groups[#groups] -- 43
		if (group and group.key) ~= key then -- 43
			group = {key = key, entries = {}} -- 45
			groups[#groups + 1] = group -- 46
		end -- 46
		local ____group_entries_2 = group.entries -- 46
		____group_entries_2[#____group_entries_2 + 1] = entry -- 48
	end -- 48
	return groups -- 50
end -- 26
____exports.normalizeFeedIndex = function(index, count) -- 53
	if count <= 0 then -- 53
		return 0 -- 54
	end -- 54
	return math.max( -- 55
		0, -- 55
		math.min( -- 55
			math.floor(index), -- 55
			count - 1 -- 55
		) -- 55
	) -- 55
end -- 53
function ____exports.resolveFeedLocation(____local, discover, target) -- 58
	if target then -- 58
		local preferred = target.kind == "discover" and discover or ____local -- 60
		local other = target.kind == "discover" and ____local or discover -- 61
		local function match(items) -- 62
			local index = target.fileName and __TS__ArrayFindIndex( -- 64
				items, -- 64
				function(____, item) return item.fileName == target.fileName end -- 64
			) or -1 -- 64
			if index < 0 and target.workDir then -- 64
				index = __TS__ArrayFindIndex( -- 65
					items, -- 65
					function(____, item) return item.workDir == target.workDir end -- 65
				) -- 65
			end -- 65
			if index < 0 then -- 65
				index = __TS__ArrayFindIndex( -- 66
					items, -- 66
					function(____, item) return item.id == target.id and item.kind == target.kind end -- 66
				) -- 66
			end -- 66
			return index -- 67
		end -- 62
		local index = match(preferred) -- 69
		if index >= 0 then -- 69
			return {tab = target.kind, index = index} -- 70
		end -- 70
		local alternate = match(other) -- 71
		if alternate >= 0 then -- 71
			return {tab = target.kind == "discover" and "local" or "discover", index = alternate} -- 72
		end -- 72
	end -- 72
	return {tab = #____local > 0 and "local" or "discover", index = 0} -- 74
end -- 58
____exports.getReusableCardIndices = function(index, count) -- 77
	if count <= 0 then -- 77
		return {} -- 78
	end -- 78
	local current = ____exports.normalizeFeedIndex(index, count) -- 79
	local result = {} -- 80
	if current > 0 then -- 80
		result[#result + 1] = current - 1 -- 81
	end -- 81
	result[#result + 1] = current -- 82
	if current + 1 < count then -- 82
		result[#result + 1] = current + 1 -- 83
	end -- 83
	return result -- 84
end -- 77
____exports.resolveFeedGesture = function(dx, dy, width, height, controlCaptured) -- 87
	if controlCaptured == nil then -- 87
		controlCaptured = false -- 92
	end -- 92
	if controlCaptured then -- 92
		return "none" -- 94
	end -- 94
	local absX = math.abs(dx) -- 95
	local absY = math.abs(dy) -- 96
	if absX < 18 and absY < 18 then -- 96
		return "none" -- 97
	end -- 97
	if absX > absY * 1.2 then -- 97
		if absX < math.max(64, width * 0.18) then -- 97
			return "none" -- 99
		end -- 99
		return dx > 0 and "remix" or "play" -- 100
	end -- 100
	if absY < math.max(72, height * 0.14) then -- 100
		return "none" -- 102
	end -- 102
	return dy > 0 and "next" or "previous" -- 103
end -- 87
____exports.stableCoverColor = function(id) -- 106
	local hash = 17 -- 107
	do -- 107
		local i = 0 -- 108
		while i < #id do -- 108
			hash = (hash * 31 + __TS__StringCharCodeAt(id, i)) % 9973 -- 108
			i = i + 1 -- 108
		end -- 108
	end -- 108
	local palette = { -- 109
		4280299593, -- 109
		4280761397, -- 109
		4282001736, -- 109
		4282790184, -- 109
		4280695880, -- 109
		4282332480 -- 109
	} -- 109
	return palette[hash % #palette + 1] -- 110
end -- 106
____exports.getCoverScales = function(sourceWidth, sourceHeight, targetWidth, targetHeight) -- 113
	if sourceWidth <= 0 or sourceHeight <= 0 or targetWidth <= 0 or targetHeight <= 0 then -- 113
		return {contain = 1, cover = 1} -- 115
	end -- 115
	return { -- 117
		contain = math.min(targetWidth / sourceWidth, targetHeight / sourceHeight), -- 118
		cover = math.max(targetWidth / sourceWidth, targetHeight / sourceHeight) -- 119
	} -- 119
end -- 113
____exports.resolveDiscoverRefreshTab = function(currentTab, userSelectedTab, previousDiscoverCount, refreshedDiscoverCount, localCount) -- 123
	if localCount == nil then -- 123
		localCount = 0 -- 128
	end -- 128
	return not userSelectedTab and localCount == 0 and previousDiscoverCount == 0 and refreshedDiscoverCount > 0 and "discover" or currentTab -- 129
end -- 123
return ____exports -- 123