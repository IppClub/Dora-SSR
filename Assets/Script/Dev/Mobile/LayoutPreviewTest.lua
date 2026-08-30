-- [ts]: LayoutPreviewTest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Feed = require("Dev.Mobile.Feed") -- 2
local startMobileFeed = ____Feed.startMobileFeed -- 2
local entries = {{id = "wide-orbit", title = "轨道花园", description = "横屏与平板布局验证作品。", kind = "discover"}, {id = "wide-runner", title = "霓虹跑者", description = "验证三卡窗口和宽屏信息区。", kind = "discover"}, {id = "wide-puzzle", title = "像素谜城", description = "验证下一张预加载边界。", kind = "discover"}} -- 4
thread(function() -- 10
	App.winSize = Size(844, 390) -- 11
	sleep(0.5) -- 12
	local host = startMobileFeed({ -- 13
		getDiscoverEntries = function() return entries end, -- 14
		getLocalEntries = function() return {} end, -- 15
		onPlay = function() return nil end, -- 16
		onRemix = function() return nil end, -- 17
		prepare = function(_entry, _repairIncomplete, _onProgress, onDone) return onDone(false, nil, "preview only") end -- 18
	}) -- 18
	sleep(0.8) -- 20
	local landscape = App:saveScreenshot("/tmp/dora-mobile-feed-landscape") -- 21
	App.winSize = Size(1024, 768) -- 22
	sleep(0.8) -- 23
	local tablet = App:saveScreenshot("/tmp/dora-mobile-feed-tablet") -- 24
	sleep(0.3) -- 25
	Content:save( -- 26
		"/tmp/dora-mobile-layout-preview.result", -- 26
		(((((("passed\nlandscape=" .. landscape) .. "\ntablet=") .. tablet) .. "\nhostScale=") .. tostring(host.scaleX)) .. ",") .. tostring(host.scaleY) -- 26
	) -- 26
end) -- 10
return ____exports -- 10