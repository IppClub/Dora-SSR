-- [ts]: CatalogMobileTest.ts
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
local ____Catalog = require("Tools.ResourceDownloader.Catalog") -- 3
local getMobileFeedResources = ____Catalog.getMobileFeedResources -- 3
local resultPath = "/tmp/dora-mobile-catalog-model.result" -- 5
local function makeResource(id, tags, mobileOrder) -- 6
	return { -- 6
		schemaVersion = 1, -- 7
		id = id, -- 8
		status = "active", -- 9
		title = {["zh-Hans"] = id, en = id}, -- 10
		description = {["zh-Hans"] = id, en = id}, -- 11
		categories = {"Game"}, -- 12
		tags = tags, -- 13
		license = {status = "pending"}, -- 14
		runnable = true, -- 15
		entrypoints = {{name = "main", path = "init"}}, -- 16
		versions = {{name = "latest", publishedAt = "2026-08-29", sources = {}}}, -- 17
		projectPath = id, -- 18
		selectedVersion = 1, -- 19
		mobileOrder = mobileOrder -- 20
	} -- 20
end -- 6
local function expect(condition, message) -- 22
	if not condition then -- 22
		error( -- 22
			__TS__New(Error, message), -- 22
			0 -- 22
		) -- 22
	end -- 22
end -- 22
do -- 22
	local function ____catch(____error) -- 22
		Content:save( -- 43
			resultPath, -- 43
			"failed: " .. tostring(____error) -- 43
		) -- 43
	end -- 43
	local ____try, ____hasReturned = pcall(function() -- 43
		local tagged = getMobileFeedResources({ -- 25
			makeResource("desktop", {}), -- 26
			makeResource("mobile-b", {"mobile-feed"}, 20), -- 27
			makeResource("mobile-a", {"mobile-feed"}, 10) -- 28
		}) -- 28
		expect(#tagged == 2, "tagged mobile resources must exclude untagged fallback entries") -- 30
		expect(tagged[1].id == "mobile-a" and tagged[2].id == "mobile-b", "tagged mobile ordering mismatch") -- 31
		local fallback = getMobileFeedResources({ -- 33
			makeResource("dora-demo", {}), -- 33
			makeResource("z-game", {}) -- 33
		}) -- 33
		expect(#fallback == 2, "runnable Catalog fallback is missing") -- 34
		expect(fallback[1].id == "dora-demo" and fallback[2].id == "z-game", "fallback ordering mismatch") -- 35
		local unavailable = makeResource("unavailable", {}) -- 36
		unavailable.status = "unavailable" -- 37
		local noEntry = makeResource("no-entry", {}) -- 38
		noEntry.entrypoints = {} -- 39
		expect( -- 40
			#getMobileFeedResources({unavailable, noEntry}) == 0, -- 40
			"fallback must reject unavailable or entryless resources" -- 40
		) -- 40
		Content:save(resultPath, "passed") -- 41
	end) -- 41
	if not ____try then -- 41
		____catch(____hasReturned) -- 41
	end -- 41
end -- 41
return ____exports -- 41