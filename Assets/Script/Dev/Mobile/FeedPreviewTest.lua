-- [ts]: FeedPreviewTest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Feed = require("Dev.Mobile.Feed") -- 2
local startMobileFeed = ____Feed.startMobileFeed -- 2
local resultPath = "/tmp/dora-mobile-feed-preview.result" -- 4
App.winSize = Size(390, 844) -- 6
thread(function() -- 7
	sleep(0.4) -- 8
	local host = startMobileFeed({ -- 9
		getDiscoverEntries = function() return {{id = "orbital-garden", title = "轨道花园", description = "守护漂浮花园，在星轨之间培育新的生态。", kind = "discover"}, {id = "neon-runner", title = "霓虹跑者", description = "一段可以立即试玩和 Remix 的节奏动作原型。", kind = "discover"}} end, -- 10
		getLocalEntries = function() return {{ -- 24
			id = "local-sample", -- 26
			title = "我的 Dora 游戏", -- 27
			description = "保存在当前设备上的可运行作品。", -- 28
			kind = "local", -- 29
			fileName = "Game/init" -- 30
		}} end, -- 30
		onPlay = function() return nil end, -- 33
		onRemix = function() return nil end, -- 34
		prepare = function(_entry, _repairIncomplete, _onProgress, onDone) return onDone(false, nil, "preview only") end -- 35
	}) -- 35
	sleep(0.8) -- 37
	local screenshot = App:saveScreenshot("/tmp/dora-mobile-feed-preview") -- 38
	sleep(0.3) -- 39
	Content:save( -- 40
		resultPath, -- 40
		(((((((((((((((((((((screenshot .. "\nvisual=") .. tostring(App.visualSize.width)) .. "x") .. tostring(App.visualSize.height)) .. " buffer=") .. tostring(App.bufferSize.width)) .. "x") .. tostring(App.bufferSize.height)) .. " dpr=") .. tostring(App.devicePixelRatio)) .. " hostScale=") .. tostring(host.scaleX)) .. ",") .. tostring(host.scaleY)) .. " safe=") .. tostring(App.safeArea.x)) .. ",") .. tostring(App.safeArea.y)) .. ",") .. tostring(App.safeArea.width)) .. ",") .. tostring(App.safeArea.height) -- 40
	) -- 40
end) -- 7
return ____exports -- 7