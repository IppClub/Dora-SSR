-- [ts]: FeedModel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local ____exports = {} -- 1
____exports.normalizeFeedIndex = function(index, count) -- 15
	if count <= 0 then -- 15
		return 0 -- 16
	end -- 16
	return math.max( -- 17
		0, -- 17
		math.min( -- 17
			math.floor(index), -- 17
			count - 1 -- 17
		) -- 17
	) -- 17
end -- 15
function ____exports.resolveFeedLocation(____local, discover, target) -- 20
	if target then -- 20
		local preferred = target.kind == "discover" and discover or ____local -- 22
		local other = target.kind == "discover" and ____local or discover -- 23
		local function match(items) -- 24
			local index = target.fileName and __TS__ArrayFindIndex( -- 26
				items, -- 26
				function(____, item) return item.fileName == target.fileName end -- 26
			) or -1 -- 26
			if index < 0 and target.workDir then -- 26
				index = __TS__ArrayFindIndex( -- 27
					items, -- 27
					function(____, item) return item.workDir == target.workDir end -- 27
				) -- 27
			end -- 27
			if index < 0 then -- 27
				index = __TS__ArrayFindIndex( -- 28
					items, -- 28
					function(____, item) return item.id == target.id and item.kind == target.kind end -- 28
				) -- 28
			end -- 28
			return index -- 29
		end -- 24
		local index = match(preferred) -- 31
		if index >= 0 then -- 31
			return {tab = target.kind, index = index} -- 32
		end -- 32
		local alternate = match(other) -- 33
		if alternate >= 0 then -- 33
			return {tab = target.kind == "discover" and "local" or "discover", index = alternate} -- 34
		end -- 34
	end -- 34
	return {tab = #____local > 0 and "local" or "discover", index = 0} -- 36
end -- 20
____exports.getReusableCardIndices = function(index, count) -- 39
	if count <= 0 then -- 39
		return {} -- 40
	end -- 40
	local current = ____exports.normalizeFeedIndex(index, count) -- 41
	local result = {} -- 42
	if current > 0 then -- 42
		result[#result + 1] = current - 1 -- 43
	end -- 43
	result[#result + 1] = current -- 44
	if current + 1 < count then -- 44
		result[#result + 1] = current + 1 -- 45
	end -- 45
	return result -- 46
end -- 39
____exports.resolveFeedGesture = function(dx, dy, width, height, controlCaptured) -- 49
	if controlCaptured == nil then -- 49
		controlCaptured = false -- 54
	end -- 54
	if controlCaptured then -- 54
		return "none" -- 56
	end -- 56
	local absX = math.abs(dx) -- 57
	local absY = math.abs(dy) -- 58
	if absX < 18 and absY < 18 then -- 58
		return "none" -- 59
	end -- 59
	if absX > absY * 1.2 then -- 59
		if absX < math.max(64, width * 0.18) then -- 59
			return "none" -- 61
		end -- 61
		return dx > 0 and "remix" or "play" -- 62
	end -- 62
	if absY < math.max(72, height * 0.14) then -- 62
		return "none" -- 64
	end -- 64
	return dy > 0 and "next" or "previous" -- 65
end -- 49
____exports.stableCoverColor = function(id) -- 68
	local hash = 17 -- 69
	do -- 69
		local i = 0 -- 70
		while i < #id do -- 70
			hash = (hash * 31 + __TS__StringCharCodeAt(id, i)) % 9973 -- 70
			i = i + 1 -- 70
		end -- 70
	end -- 70
	local palette = { -- 71
		4280299593, -- 71
		4280761397, -- 71
		4282001736, -- 71
		4282790184, -- 71
		4280695880, -- 71
		4282332480 -- 71
	} -- 71
	return palette[hash % #palette + 1] -- 72
end -- 68
____exports.getCoverScales = function(sourceWidth, sourceHeight, targetWidth, targetHeight) -- 75
	if sourceWidth <= 0 or sourceHeight <= 0 or targetWidth <= 0 or targetHeight <= 0 then -- 75
		return {contain = 1, cover = 1} -- 77
	end -- 77
	return { -- 79
		contain = math.min(targetWidth / sourceWidth, targetHeight / sourceHeight), -- 80
		cover = math.max(targetWidth / sourceWidth, targetHeight / sourceHeight) -- 81
	} -- 81
end -- 75
____exports.resolveDiscoverRefreshTab = function(currentTab, userSelectedTab, previousDiscoverCount, refreshedDiscoverCount, localCount) -- 85
	if localCount == nil then -- 85
		localCount = 0 -- 90
	end -- 90
	return not userSelectedTab and localCount == 0 and previousDiscoverCount == 0 and refreshedDiscoverCount > 0 and "discover" or currentTab -- 91
end -- 85
return ____exports -- 85