-- [ts]: RemixPreviewTest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Remix = require("Dev.Mobile.Remix") -- 2
local startMobileRemix = ____Remix.startMobileRemix -- 2
local resultPath = "/tmp/dora-mobile-remix-preview.result" -- 4
App.winSize = Size(390, 844) -- 6
thread(function() -- 7
	sleep(0.4) -- 8
	local host = startMobileRemix({ -- 9
		entry = {id = "mobile-remix-preview", title = "轨道花园", workDir = Content.assetPath, fileName = "Script/Dev/Mobile/FeedPreviewTest"}, -- 10
		onBack = function() return nil end, -- 16
		onPlay = function() return nil end -- 17
	}) -- 17
	sleep(0.8) -- 19
	local screenshot = App:saveScreenshot("/tmp/dora-mobile-remix-preview") -- 20
	sleep(0.3) -- 21
	Content:save( -- 22
		resultPath, -- 22
		(((((((((screenshot .. "\nvisual=") .. tostring(App.visualSize.width)) .. "x") .. tostring(App.visualSize.height)) .. " dpr=") .. tostring(App.devicePixelRatio)) .. " hostScale=") .. tostring(host.scaleX)) .. ",") .. tostring(host.scaleY) -- 22
	) -- 22
end) -- 7
return ____exports -- 7