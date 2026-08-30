-- [ts]: FeedModeSwitchTest.ts
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
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Feed = require("Dev.Mobile.Feed") -- 2
local startMobileFeed = ____Feed.startMobileFeed -- 2
local resultPath = Path(Content.writablePath, "dora-feed-mode-switch.result") -- 4
Content:save(resultPath, "running\n") -- 5
local function expect(condition, message) -- 6
	if condition then -- 6
		return -- 7
	end -- 7
	Content:save(resultPath, ("failed " .. message) .. "\n") -- 8
	error( -- 9
		__TS__New(Error, message), -- 9
		0 -- 9
	) -- 9
end -- 6
local function find(root, tag) -- 11
	if root.tag == tag then -- 11
		return root -- 12
	end -- 12
	local result -- 13
	root:eachChild(function(child) -- 14
		result = find(child, tag) -- 14
		return result ~= nil -- 14
	end) -- 14
	return result -- 15
end -- 11
thread(function() -- 17
	local switched = 0 -- 18
	local played = 0 -- 19
	local progress -- 20
	local done -- 21
	local synced -- 22
	local host = startMobileFeed({ -- 23
		getDiscoverEntries = function() return {{id = "test", title = "Mode test", description = "Test", kind = "discover"}} end, -- 24
		getLocalEntries = function() return {} end, -- 25
		onPlay = function() -- 26
			played = played + 1 -- 26
		end, -- 26
		onRemix = function() return nil end, -- 27
		onSwitchMode = function() -- 28
			switched = switched + 1 -- 28
		end, -- 28
		prepare = function(_entry, _repair, onProgress, onDone) -- 29
			progress = onProgress -- 29
			done = onDone -- 29
		end, -- 29
		syncDiscover = function(_progress, onDone) -- 30
			synced = onDone -- 30
		end -- 30
	}) -- 30
	expect( -- 32
		find(host, "mobile-ui-mode-switch") ~= nil, -- 32
		"mode button missing" -- 32
	) -- 32
	local ____opt_0 = find(host, "mobile-feed-play") -- 32
	if ____opt_0 ~= nil then -- 32
		____opt_0:emit("Tapped") -- 33
	end -- 33
	expect(done ~= nil, "install was not started") -- 34
	host:emit("SwitchUIMode") -- 35
	local ____opt_2 = find(host, "mobile-ui-mode-switch") -- 35
	if ____opt_2 ~= nil then -- 35
		____opt_2:emit("Tapped") -- 36
	end -- 36
	expect(switched == 0, "switch allowed during installation") -- 37
	host:removeFromParent(true) -- 38
	local ____opt_4 = host.children -- 38
	local childCount = ____opt_4 and ____opt_4.count or 0 -- 39
	if progress ~= nil then -- 39
		progress(0.5, "late progress") -- 40
	end -- 40
	if done ~= nil then -- 40
		done(true, {fileName = "test/init", workDir = "test"}) -- 41
	end -- 41
	if synced ~= nil then -- 41
		synced(true) -- 42
	end -- 42
	host:emit("SwitchUIMode") -- 43
	sleep(0.05) -- 44
	expect(played == 0 and switched == 0, "late callback activated a disposed Feed") -- 45
	local ____expect_14 = expect -- 46
	local ____opt_12 = host.children -- 46
	____expect_14((____opt_12 and ____opt_12.count or 0) == childCount, "late callback rebuilt a disposed Feed") -- 46
	local idle = startMobileFeed({ -- 47
		getDiscoverEntries = function() return {} end, -- 48
		getLocalEntries = function() return {{ -- 49
			id = "local", -- 49
			title = "Local", -- 49
			description = "Test", -- 49
			kind = "local", -- 49
			fileName = "test/init" -- 49
		}} end, -- 49
		onPlay = function() -- 50
			played = played + 1 -- 50
		end, -- 50
		onRemix = function() -- 51
			played = played + 1 -- 51
		end, -- 51
		onSwitchMode = function() -- 52
			switched = switched + 1 -- 52
		end, -- 52
		prepare = function() return nil end -- 53
	}) -- 53
	local ____opt_15 = find(idle, "mobile-ui-mode-switch") -- 53
	if ____opt_15 ~= nil then -- 53
		____opt_15:emit("Tapped") -- 55
	end -- 55
	idle:emit("SwitchUIMode") -- 56
	local ____opt_17 = find(idle, "mobile-feed-play") -- 56
	if ____opt_17 ~= nil then -- 56
		____opt_17:emit("Tapped") -- 57
	end -- 57
	local ____opt_19 = find(idle, "mobile-feed-remix") -- 57
	if ____opt_19 ~= nil then -- 57
		____opt_19:emit("Tapped") -- 58
	end -- 58
	expect(switched == 1 and played == 0, "same-frame double click reopened a leaving Feed") -- 59
	idle:removeFromParent(true) -- 60
	Content:save(resultPath, "passed installGuard=1 lateCallbacks=1 disposedHost=1 reentryGuard=1\n") -- 61
end) -- 17
return ____exports -- 17