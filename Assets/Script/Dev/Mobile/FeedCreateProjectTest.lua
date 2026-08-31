-- [ts]: FeedCreateProjectTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local emit = ____Dora.emit -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Feed = require("Dev.Mobile.Feed") -- 2
local startMobileFeed = ____Feed.startMobileFeed -- 2
local resultPath = Path(Content.writablePath, "dora-feed-create-project.result") -- 5
Content:save(resultPath, "running\n") -- 6
local function expect(condition, message) -- 8
	if condition then -- 8
		return -- 9
	end -- 9
	Content:save(resultPath, ("failed " .. message) .. "\n") -- 10
	error( -- 11
		__TS__New(Error, message), -- 11
		0 -- 11
	) -- 11
end -- 8
local function find(root, tag) -- 14
	if root.tag == tag then -- 14
		return root -- 15
	end -- 15
	local result -- 16
	root:eachChild(function(child) -- 17
		result = find(child, tag) -- 17
		return result ~= nil -- 17
	end) -- 17
	return result -- 18
end -- 14
thread(function() -- 21
	local ____local = {} -- 22
	local attempts = 0 -- 23
	local remixCount = 0 -- 24
	local remixed -- 25
	local host -- 26
	host = startMobileFeed({ -- 27
		getDiscoverEntries = function() return {} end, -- 28
		getLocalEntries = function() return ____local end, -- 29
		onPlay = function() return nil end, -- 30
		onRemix = function(entry) -- 31
			remixCount = remixCount + 1 -- 31
			remixed = entry -- 31
		end, -- 31
		prepare = function() return nil end, -- 32
		createProject = function(name) -- 33
			attempts = attempts + 1 -- 34
			local ____opt_0 = find(host, "mobile-project-create-submit") -- 34
			if ____opt_0 ~= nil then -- 34
				____opt_0:emit("Tapped") -- 35
			end -- 35
			if attempts == 1 then -- 35
				return {success = false, error = "target-existed"} -- 36
			end -- 36
			local entry = { -- 37
				id = "new-game", -- 37
				title = name, -- 37
				description = "Local", -- 37
				kind = "local", -- 37
				fileName = "/workspace/New Game/init", -- 37
				workDir = "/workspace/New Game" -- 37
			} -- 37
			____local[#____local + 1] = entry -- 38
			return {success = true, entry = entry} -- 39
		end -- 33
	}) -- 33
	expect( -- 43
		find(host, "mobile-feed-create") == nil, -- 43
		"create button leaked into Discover" -- 43
	) -- 43
	local ____opt_2 = find(host, "mobile-feed-local-tab") -- 43
	if ____opt_2 ~= nil then -- 43
		____opt_2:emit("Tapped") -- 44
	end -- 44
	expect( -- 45
		find(host, "mobile-feed-create") ~= nil, -- 45
		"empty Local feed has no create button" -- 45
	) -- 45
	local ____opt_4 = find(host, "mobile-feed-create") -- 45
	if ____opt_4 ~= nil then -- 45
		____opt_4:emit("Tapped") -- 47
	end -- 47
	expect( -- 48
		find(host, "mobile-project-create-sheet") ~= nil, -- 48
		"create sheet did not open" -- 48
	) -- 48
	local ____opt_6 = find(host, "mobile-project-create-cancel") -- 48
	if ____opt_6 ~= nil then -- 48
		____opt_6:emit("Tapped") -- 49
	end -- 49
	expect( -- 50
		find(host, "mobile-project-create-sheet") == nil, -- 50
		"cancel did not close create sheet" -- 50
	) -- 50
	local ____opt_8 = find(host, "mobile-feed-create") -- 50
	if ____opt_8 ~= nil then -- 50
		____opt_8:emit("Tapped") -- 52
	end -- 52
	local ____opt_10 = find(host, "mobile-project-create-input") -- 52
	if ____opt_10 ~= nil then -- 52
		____opt_10:emit("TextInput", "New Game") -- 53
	end -- 53
	local ____opt_12 = find(host, "mobile-project-create-submit") -- 53
	if ____opt_12 ~= nil then -- 53
		____opt_12:emit("Tapped") -- 54
	end -- 54
	expect(attempts == 1, "create allowed a reentrant duplicate submission") -- 55
	expect( -- 56
		find(host, "mobile-project-create-sheet") ~= nil, -- 56
		"recoverable failure closed the sheet" -- 56
	) -- 56
	expect( -- 57
		find(host, "mobile-project-create-error") ~= nil, -- 57
		"recoverable failure has no error message" -- 57
	) -- 57
	local ____opt_14 = find(host, "mobile-project-create-submit") -- 57
	if ____opt_14 ~= nil then -- 57
		____opt_14:emit("Tapped") -- 59
	end -- 59
	expect(attempts == 2 and remixCount == 1, "successful create did not enter Remix exactly once") -- 60
	expect((remixed and remixed.workDir) == "/workspace/New Game", "successful create selected the wrong project") -- 61
	expect( -- 62
		find(host, "mobile-feed-card-new-game") ~= nil, -- 62
		"new local project was not selected before Remix" -- 62
	) -- 62
	host:emit("RestoreFeedEntry", remixed) -- 64
	expect( -- 65
		find(host, "mobile-feed-card-new-game") ~= nil, -- 65
		"return from Remix lost the new project card" -- 65
	) -- 65
	local ____opt_18 = find(host, "mobile-feed-create") -- 65
	if ____opt_18 ~= nil then -- 65
		____opt_18:emit("Tapped") -- 67
	end -- 67
	local muted = {} -- 70
	local muteOtherBackHandlers -- 71
	muteOtherBackHandlers = function(node) -- 71
		if node ~= host then -- 71
			__TS__ArrayForEach( -- 72
				node:gslot("AppEvent") or ({}), -- 72
				function(____, slot) -- 72
					if slot.enabled then -- 72
						slot.enabled = false -- 73
						muted[#muted + 1] = slot -- 73
					end -- 73
				end -- 72
			) -- 72
		end -- 72
		node:eachChild(function(child) -- 75
			muteOtherBackHandlers(child) -- 75
			return false -- 75
		end) -- 75
	end -- 71
	muteOtherBackHandlers(Director.systemUI) -- 77
	muteOtherBackHandlers(Director.entry) -- 78
	emit("AppEvent", "BackButton") -- 79
	__TS__ArrayForEach( -- 80
		muted, -- 80
		function(____, slot) -- 80
			slot.enabled = true -- 80
		end -- 80
	) -- 80
	expect( -- 81
		find(host, "mobile-project-create-sheet") == nil, -- 81
		"Back did not close create sheet" -- 81
	) -- 81
	host:removeFromParent(true) -- 83
	sleep(0.05) -- 84
	Content:save(resultPath, "passed empty=1 cancel=1 reentry=1 recovery=1 success=1 restore=1 back=1\n") -- 85
end) -- 21
return ____exports -- 21