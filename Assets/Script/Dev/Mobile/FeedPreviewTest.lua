-- [ts]: FeedPreviewTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Feed = require("Dev.Mobile.Feed") -- 2
local startMobileFeed = ____Feed.startMobileFeed -- 2
local resultPath = "/tmp/dora-mobile-feed-preview.result" -- 4
local function find(root, tag) -- 6
	if root.tag == tag then -- 6
		return root -- 7
	end -- 7
	local result -- 8
	root:eachChild(function(child) -- 9
		result = find(child, tag) -- 9
		return result ~= nil -- 9
	end) -- 9
	return result -- 10
end -- 6
local function findPrefix(root, prefix) -- 13
	if string.sub(root.tag, 1, #prefix) == prefix then -- 13
		return root -- 14
	end -- 14
	local result -- 15
	root:eachChild(function(child) -- 16
		result = findPrefix(child, prefix) -- 16
		return result ~= nil -- 16
	end) -- 16
	return result -- 17
end -- 13
local function expect(condition, message) -- 20
	if not condition then -- 20
		error( -- 21
			__TS__New(Error, message), -- 21
			0 -- 21
		) -- 21
	end -- 21
end -- 20
App.winSize = Size(390, 844) -- 24
thread(function() -- 25
	sleep(0.4) -- 26
	local host = startMobileFeed({ -- 27
		getDiscoverEntries = function() return {{id = "orbital-garden", title = "轨道花园", description = "守护漂浮花园，在星轨之间培育新的生态。", kind = "discover"}, {id = "neon-runner", title = "霓虹跑者", description = "一段可以立即试玩和 Remix 的节奏动作原型。", kind = "discover"}} end, -- 28
		getLocalEntries = function() return {{ -- 42
			id = "local-sample", -- 44
			title = "我的 Dora 游戏", -- 45
			description = "保存在当前设备上的可运行作品。", -- 46
			kind = "local", -- 47
			fileName = "Game/init" -- 48
		}} end, -- 48
		onPlay = function() return nil end, -- 51
		onRemix = function() return nil end, -- 52
		onSwitchMode = function() return nil end, -- 53
		createProject = function() return {success = false, error = "preview only"} end, -- 54
		prepare = function(_entry, _repairIncomplete, _onProgress, onDone) return onDone(false, nil, "preview only") end -- 55
	}) -- 55
	sleep(0.8) -- 57
	local screenshot = App:saveScreenshot("/tmp/dora-mobile-feed-preview") -- 58
	sleep(0.3) -- 59
	local scene = find(host, "mobile-feed-scene") -- 60
	local header = find(host, "mobile-feed-header") -- 61
	local card = findPrefix(host, "mobile-feed-card-") -- 62
	local indexBadge = find(host, "mobile-feed-index") -- 63
	expect(header.order > card.order, "dragging card can cover the fixed header") -- 64
	scene:emit("TapBegan") -- 65
	scene:emit( -- 66
		"TapMoved", -- 66
		{delta = Vec2(0, 720)} -- 66
	) -- 66
	expect(card.position.y > 0, "vertical drag preview did not move the card") -- 67
	expect(indexBadge.opacity == 0, "dragging index remained visible inside the fixed header") -- 68
	sleep(0.2) -- 69
	local dragScreenshot = App:saveScreenshot("/tmp/dora-mobile-feed-drag-layer") -- 70
	sleep(0.3) -- 71
	Content:save( -- 72
		resultPath, -- 72
		(((((((((((((((((((((((((((((screenshot .. "\n") .. dragScreenshot) .. "\nvisual=") .. tostring(App.visualSize.width)) .. "x") .. tostring(App.visualSize.height)) .. " buffer=") .. tostring(App.bufferSize.width)) .. "x") .. tostring(App.bufferSize.height)) .. " dpr=") .. tostring(App.devicePixelRatio)) .. " hostScale=") .. tostring(host.scaleX)) .. ",") .. tostring(host.scaleY)) .. " safe=") .. tostring(App.safeArea.x)) .. ",") .. tostring(App.safeArea.y)) .. ",") .. tostring(App.safeArea.width)) .. ",") .. tostring(App.safeArea.height)) .. "\nheaderOrder=") .. tostring(header.order)) .. " cardOrder=") .. tostring(card.order)) .. " cardY=") .. tostring(card.position.y) -- 72
	) -- 72
end) -- 25
return ____exports -- 25