-- [ts]: FeedModelTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 2
local getReusableCardIndices = ____FeedModel.getReusableCardIndices -- 3
local getCoverScales = ____FeedModel.getCoverScales -- 4
local normalizeFeedIndex = ____FeedModel.normalizeFeedIndex -- 5
local resolveDiscoverRefreshTab = ____FeedModel.resolveDiscoverRefreshTab -- 6
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 7
local resolveFeedLocation = ____FeedModel.resolveFeedLocation -- 8
local stableCoverColor = ____FeedModel.stableCoverColor -- 9
local resultPath = "/tmp/dora-mobile-feed-model.result" -- 12
local function expect(condition, message) -- 14
	if not condition then -- 14
		error( -- 15
			__TS__New(Error, message), -- 15
			0 -- 15
		) -- 15
	end -- 15
end -- 14
do -- 14
	local function ____catch(____error) -- 14
		Content:save( -- 56
			resultPath, -- 56
			"failed: " .. tostring(____error) -- 56
		) -- 56
	end -- 56
	local ____try, ____hasReturned = pcall(function() -- 56
		expect( -- 19
			normalizeFeedIndex(-4, 5) == 0, -- 19
			"negative index should clamp to zero" -- 19
		) -- 19
		expect( -- 20
			normalizeFeedIndex(8, 5) == 4, -- 20
			"large index should clamp to the last card" -- 20
		) -- 20
		expect( -- 21
			normalizeFeedIndex(2.8, 5) == 2, -- 21
			"fractional index should be floored" -- 21
		) -- 21
		expect( -- 22
			table.concat( -- 22
				getReusableCardIndices(0, 8), -- 22
				"," -- 22
			) == "0,1", -- 22
			"first card pool mismatch" -- 22
		) -- 22
		expect( -- 23
			table.concat( -- 23
				getReusableCardIndices(4, 8), -- 23
				"," -- 23
			) == "3,4,5", -- 23
			"middle card pool mismatch" -- 23
		) -- 23
		expect( -- 24
			table.concat( -- 24
				getReusableCardIndices(7, 8), -- 24
				"," -- 24
			) == "6,7", -- 24
			"last card pool mismatch" -- 24
		) -- 24
		expect( -- 25
			table.concat( -- 25
				getReusableCardIndices(50, 100), -- 25
				"," -- 25
			) == "49,50,51", -- 25
			"long-list pool must stay capped at three cards" -- 25
		) -- 25
		do -- 25
			local i = 0 -- 26
			while i < 10000 do -- 26
				local pool = getReusableCardIndices(i % 1000, 1000) -- 27
				expect(#pool <= 3, "rapid long-list paging exceeded the three-card window") -- 28
				i = i + 1 -- 26
			end -- 26
		end -- 26
		expect( -- 30
			resolveFeedGesture(220, 10, 400, 800) == "remix", -- 30
			"right swipe should open Remix" -- 30
		) -- 30
		expect( -- 31
			resolveFeedGesture(-220, 10, 400, 800) == "play", -- 31
			"left swipe should start Play" -- 31
		) -- 31
		expect( -- 32
			resolveFeedGesture(4, 160, 400, 800) == "next", -- 32
			"vertical swipe should advance" -- 32
		) -- 32
		expect( -- 33
			resolveFeedGesture( -- 33
				220, -- 33
				10, -- 33
				400, -- 33
				800, -- 33
				true -- 33
			) == "none", -- 33
			"captured control should suppress gestures" -- 33
		) -- 33
		expect( -- 34
			stableCoverColor("same-id") == stableCoverColor("same-id"), -- 34
			"cover color should be stable" -- 34
		) -- 34
		expect( -- 35
			resolveDiscoverRefreshTab("local", false, 0, 1) == "discover", -- 35
			"first Catalog result should open Discover" -- 35
		) -- 35
		expect( -- 36
			resolveDiscoverRefreshTab("local", true, 0, 1) == "local", -- 36
			"user-selected Local tab must be preserved" -- 36
		) -- 36
		expect( -- 37
			resolveDiscoverRefreshTab("discover", true, 1, 2) == "discover", -- 37
			"Discover refresh must preserve active tab" -- 37
		) -- 37
		expect( -- 38
			resolveDiscoverRefreshTab("local", false, 0, 0) == "local", -- 38
			"empty Catalog refresh must not switch tabs" -- 38
		) -- 38
		expect( -- 39
			resolveDiscoverRefreshTab( -- 39
				"local", -- 39
				false, -- 39
				0, -- 39
				2, -- 39
				3 -- 39
			) == "local", -- 39
			"Catalog sync stole Local with existing projects" -- 39
		) -- 39
		local locals = __TS__ArrayMap( -- 40
			{"A", "B", "C"}, -- 40
			function(____, id) return { -- 40
				id = id, -- 40
				title = id, -- 40
				description = "", -- 40
				kind = "local", -- 40
				fileName = id .. "/init", -- 40
				workDir = id -- 40
			} end -- 40
		) -- 40
		local discover = {__TS__ObjectAssign({}, locals[2], {id = "catalog-B", kind = "discover"})} -- 41
		expect( -- 42
			resolveFeedLocation(locals, discover).tab == "local", -- 42
			"Local must be the default" -- 42
		) -- 42
		expect( -- 43
			resolveFeedLocation({}, discover).tab == "discover", -- 43
			"Empty Local must show Discover" -- 43
		) -- 43
		expect( -- 44
			resolveFeedLocation({locals[3], locals[1], locals[2]}, discover, locals[2]).index == 2, -- 44
			"Return must follow reordered project" -- 44
		) -- 44
		expect( -- 45
			resolveFeedLocation(locals, discover, discover[1]).tab == "discover", -- 45
			"Return should retain origin tab" -- 45
		) -- 45
		expect( -- 46
			resolveFeedLocation(locals, {}, discover[1]).index == 1, -- 46
			"Installed Catalog project should match local path" -- 46
		) -- 46
		expect( -- 47
			resolveFeedLocation( -- 47
				{__TS__ObjectAssign({}, locals[2], {id = "renamed"})}, -- 47
				{}, -- 47
				locals[2] -- 47
			).index == 0, -- 47
			"Rename must retain project identity" -- 47
		) -- 47
		local landscapeScales = getCoverScales(1920, 1080, 390, 390) -- 48
		expect( -- 49
			math.abs(landscapeScales.contain - 390 / 1920) < 0.0001, -- 49
			"landscape cover contain scale mismatch" -- 49
		) -- 49
		expect( -- 50
			math.abs(landscapeScales.cover - 390 / 1080) < 0.0001, -- 50
			"landscape cover fill scale mismatch" -- 50
		) -- 50
		local portraitScales = getCoverScales(600, 900, 400, 240) -- 51
		expect( -- 52
			math.abs(portraitScales.contain - 240 / 900) < 0.0001, -- 52
			"portrait cover contain scale mismatch" -- 52
		) -- 52
		expect( -- 53
			math.abs(portraitScales.cover - 400 / 600) < 0.0001, -- 53
			"portrait cover fill scale mismatch" -- 53
		) -- 53
		Content:save(resultPath, "passed") -- 54
	end) -- 54
	if not ____try then -- 54
		____catch(____hasReturned) -- 54
	end -- 54
end -- 54
return ____exports -- 54