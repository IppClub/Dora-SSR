-- [ts]: CatalogInstallIntegrationTest.ts
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
local ____Lifecycle = require("Dev.Mobile.Lifecycle") -- 3
local isMobileResourceReady = ____Lifecycle.isMobileResourceReady -- 3
local prepareMobileResource = ____Lifecycle.prepareMobileResource -- 3
local resultPath = "/tmp/dora-mobile-catalog-install-integration.result" -- 5
local testWritablePath = "/tmp/dora-mobile-catalog-install-integration" -- 6
local originalWritablePath = Content.writablePath -- 7
local resource = { -- 8
	schemaVersion = 1, -- 9
	id = "dora-demo-mobile-integration", -- 10
	status = "active", -- 11
	title = {["zh-Hans"] = "Dora 演示", en = "Dora Demo"}, -- 12
	description = {["zh-Hans"] = "真实 Catalog 安装集成测试", en = "Real Catalog installation integration test"}, -- 13
	categories = {"Dora"}, -- 14
	tags = {"mobile-feed"}, -- 15
	license = {status = "pending"}, -- 16
	runnable = true, -- 17
	entrypoints = {{name = "AI Fighter", path = "AI Fighter/init"}}, -- 18
	versions = {{name = "latest", publishedAt = "2026-07-27T00:00:00.000Z", sources = {{role = "upstream", url = "https://gitcode.com/ippclub/dora-demo"}}}}, -- 19
	projectPath = "dora-demo", -- 24
	selectedVersion = 1 -- 25
} -- 25
thread(function() -- 28
	Content:save(resultPath, "running") -- 29
	do -- 29
		local function ____catch(____error) -- 29
			Content:save( -- 49
				resultPath, -- 49
				"failed: " .. tostring(____error) -- 49
			) -- 49
		end -- 49
		local ____try, ____hasReturned = pcall(function() -- 49
			if Content:exist(testWritablePath) then -- 49
				Content:remove(testWritablePath) -- 31
			end -- 31
			Content:mkdir(testWritablePath) -- 32
			Content.writablePath = testWritablePath -- 33
			local completed = false -- 34
			local progressEvents = 0 -- 35
			local failure = "" -- 36
			prepareMobileResource( -- 37
				resource, -- 37
				"live-catalog-integration", -- 37
				function() -- 37
					progressEvents = progressEvents + 1 -- 37
				end, -- 37
				function(result) -- 37
					if not result.success or not result.entry then -- 37
						failure = result.message or "installation failed" -- 38
					elseif not isMobileResourceReady(resource) then -- 38
						failure = "installed Catalog resource is not ready" -- 39
					elseif not Content:exist(Path(result.entry.workDir, ".dora", "resource-state.json")) then -- 39
						failure = "resource state metadata is missing" -- 40
					end -- 40
					completed = true -- 41
				end -- 37
			) -- 37
			do -- 37
				local i = 0 -- 43
				while i < 3600 and not completed do -- 43
					sleep(0.05) -- 43
					i = i + 1 -- 43
				end -- 43
			end -- 43
			if not completed then -- 43
				error( -- 44
					__TS__New(Error, "real Catalog installation timed out"), -- 44
					0 -- 44
				) -- 44
			end -- 44
			if failure ~= "" then -- 44
				error( -- 45
					__TS__New(Error, failure), -- 45
					0 -- 45
				) -- 45
			end -- 45
			if progressEvents < 3 then -- 45
				error( -- 46
					__TS__New(Error, "installation progress did not report enough stages"), -- 46
					0 -- 46
				) -- 46
			end -- 46
			Content:save( -- 47
				resultPath, -- 47
				"passed: source=gitcode progressEvents=" .. tostring(progressEvents) -- 47
			) -- 47
		end) -- 47
		if not ____try then -- 47
			____catch(____hasReturned) -- 47
		end -- 47
	end -- 47
	Content.writablePath = originalWritablePath -- 51
	if Content:exist(testWritablePath) then -- 51
		Content:remove(testWritablePath) -- 52
	end -- 52
end) -- 28
return ____exports -- 28