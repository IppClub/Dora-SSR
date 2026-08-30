-- [ts]: LifecycleTest.ts
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
local resolveMobileLaunchEntry = ____Lifecycle.resolveMobileLaunchEntry -- 3
local originalWritablePath = Content.writablePath -- 5
local testWritablePath = "/tmp/dora-mobile-lifecycle-test" -- 6
local function makeResource(id, versions) -- 7
	return { -- 7
		schemaVersion = 1, -- 8
		id = id, -- 9
		status = "active", -- 10
		title = {["zh-Hans"] = "已安装作品", en = "Installed Game"}, -- 11
		description = {["zh-Hans"] = "测试", en = "Test"}, -- 12
		categories = {"game"}, -- 13
		tags = {"mobile-feed"}, -- 14
		license = {status = "confirmed", spdx = "MIT"}, -- 15
		runnable = true, -- 16
		entrypoints = {{name = "main", path = "init.lua"}}, -- 17
		versions = versions, -- 18
		projectPath = id, -- 19
		selectedVersion = 1 -- 20
	} -- 20
end -- 7
local resource = makeResource("installed-game", {{name = "test", publishedAt = "2026-08-29", sources = {}}}) -- 22
local moduleResource = makeResource("module-game", {{name = "test", publishedAt = "2026-08-29", sources = {}}}) -- 23
moduleResource.entrypoints[1].path = "Game/init" -- 24
local unavailableResource = makeResource("unavailable-game", {}) -- 25
local incompleteResource = makeResource("incomplete-game", {{name = "test", publishedAt = "2026-08-29", sources = {}}}) -- 26
thread(function() -- 28
	Content:save("/tmp/dora-mobile-lifecycle.result", "running") -- 29
	do -- 29
		local function ____catch(____error) -- 29
			Content:save( -- 97
				"/tmp/dora-mobile-lifecycle.result", -- 97
				"failed: " .. tostring(____error) -- 97
			) -- 97
		end -- 97
		local ____try, ____hasReturned = pcall(function() -- 97
			if Content:exist(testWritablePath) then -- 97
				Content:remove(testWritablePath) -- 31
			end -- 31
			Content:mkdir(testWritablePath) -- 32
			Content.writablePath = testWritablePath -- 33
			local downloadPath = Path(testWritablePath, "Download") -- 34
			local installPath = Path(downloadPath, resource.id) -- 35
			Content:mkdir(downloadPath) -- 36
			Content:mkdir(installPath) -- 37
			Content:save( -- 38
				Path(installPath, "init.lua"), -- 38
				"return function() end\n" -- 38
			) -- 38
			if not isMobileResourceReady(resource) then -- 38
				error( -- 39
					__TS__New(Error, "installed resource readiness mismatch"), -- 39
					0 -- 39
				) -- 39
			end -- 39
			local completed = false -- 40
			prepareMobileResource( -- 41
				resource, -- 41
				"test-commit", -- 41
				function() return nil end, -- 41
				function(result) -- 41
					if not result.success or not result.entry then -- 41
						error( -- 42
							__TS__New(Error, result.message or "installed resource was not resolved"), -- 42
							0 -- 42
						) -- 42
					end -- 42
					if result.entry.workDir ~= installPath then -- 42
						error( -- 43
							__TS__New(Error, "installed workDir mismatch"), -- 43
							0 -- 43
						) -- 43
					end -- 43
					if result.entry.fileName ~= Path(installPath, "init") then -- 43
						error( -- 44
							__TS__New(Error, "installed entrypoint mismatch"), -- 44
							0 -- 44
						) -- 44
					end -- 44
					completed = true -- 45
				end -- 41
			) -- 41
			if not completed then -- 41
				error( -- 47
					__TS__New(Error, "installed callback did not complete synchronously"), -- 47
					0 -- 47
				) -- 47
			end -- 47
			local modulePath = Path(downloadPath, moduleResource.id) -- 49
			Content:mkdir(modulePath) -- 50
			Content:mkdir(Path(modulePath, "Game")) -- 51
			Content:save( -- 52
				Path(modulePath, "Game", "init.lua"), -- 52
				"return function() end\n" -- 52
			) -- 52
			if not isMobileResourceReady(moduleResource) then -- 52
				error( -- 53
					__TS__New(Error, "extensionless module entrypoint was not resolved"), -- 53
					0 -- 53
				) -- 53
			end -- 53
			local moduleCompleted = false -- 54
			prepareMobileResource( -- 55
				moduleResource, -- 55
				"test-commit", -- 55
				function() return nil end, -- 55
				function(result) -- 55
					local ____temp_2 = not result.success -- 56
					if not ____temp_2 then -- 56
						local ____opt_0 = result.entry -- 56
						____temp_2 = (____opt_0 and ____opt_0.fileName) ~= Path(modulePath, "Game", "init") -- 56
					end -- 56
					if ____temp_2 then -- 56
						error( -- 57
							__TS__New(Error, "extensionless installed entrypoint mismatch"), -- 57
							0 -- 57
						) -- 57
					end -- 57
					moduleCompleted = true -- 59
				end -- 55
			) -- 55
			if not moduleCompleted then -- 55
				error( -- 61
					__TS__New(Error, "extensionless module callback did not complete synchronously"), -- 61
					0 -- 61
				) -- 61
			end -- 61
			local launchEntry = resolveMobileLaunchEntry({ -- 62
				fileName = Path(modulePath, "Game", "init"), -- 62
				workDir = modulePath -- 62
			}) -- 62
			if launchEntry.fileName ~= Path(modulePath, "Game", "init") or launchEntry.workDir ~= Path(modulePath, "Game") then -- 62
				error( -- 64
					__TS__New(Error, "play launch workDir must resolve from the selected entrypoint"), -- 64
					0 -- 64
				) -- 64
			end -- 64
			local unavailableCompleted = false -- 67
			prepareMobileResource( -- 68
				unavailableResource, -- 68
				"test-commit", -- 68
				function() return nil end, -- 68
				function(result) -- 68
					if result.success or result.message ~= "resource version is unavailable" then -- 68
						error( -- 69
							__TS__New(Error, "unavailable version mismatch"), -- 69
							0 -- 69
						) -- 69
					end -- 69
					unavailableCompleted = true -- 70
				end -- 68
			) -- 68
			if not unavailableCompleted then -- 68
				error( -- 72
					__TS__New(Error, "unavailable callback did not complete synchronously"), -- 72
					0 -- 72
				) -- 72
			end -- 72
			local incompletePath = Path(downloadPath, incompleteResource.id) -- 74
			Content:mkdir(incompletePath) -- 75
			Content:save( -- 76
				Path(incompletePath, "user-note.txt"), -- 76
				"preserve me\n" -- 76
			) -- 76
			if isMobileResourceReady(incompleteResource) then -- 76
				error( -- 77
					__TS__New(Error, "incomplete resource must not be ready"), -- 77
					0 -- 77
				) -- 77
			end -- 77
			local repairPrompted = false -- 78
			prepareMobileResource( -- 79
				incompleteResource, -- 79
				"test-commit", -- 79
				function() return nil end, -- 79
				function(result) -- 79
					if result.success or not result.repairable then -- 79
						error( -- 80
							__TS__New(Error, "incomplete resource must request repair confirmation"), -- 80
							0 -- 80
						) -- 80
					end -- 80
					repairPrompted = true -- 81
				end -- 79
			) -- 79
			if not repairPrompted then -- 79
				error( -- 83
					__TS__New(Error, "repair prompt did not complete synchronously"), -- 83
					0 -- 83
				) -- 83
			end -- 83
			local repairCompleted = false -- 85
			prepareMobileResource( -- 86
				incompleteResource, -- 86
				"test-commit", -- 86
				function() return nil end, -- 86
				function(result) -- 86
					if result.success or (string.match(result.message or "", "previous installation restored")) == nil then -- 86
						error( -- 88
							__TS__New( -- 88
								Error, -- 88
								"repair rollback mismatch: " .. tostring(result.message) -- 88
							), -- 88
							0 -- 88
						) -- 88
					end -- 88
					repairCompleted = true -- 90
				end, -- 86
				true -- 91
			) -- 91
			do -- 91
				local i = 0 -- 92
				while i < 100 and not repairCompleted do -- 92
					sleep(0.01) -- 92
					i = i + 1 -- 92
				end -- 92
			end -- 92
			if not repairCompleted then -- 92
				error( -- 93
					__TS__New(Error, "repair callback timed out"), -- 93
					0 -- 93
				) -- 93
			end -- 93
			if not Content:exist(Path(incompletePath, "user-note.txt")) then -- 93
				error( -- 94
					__TS__New(Error, "failed repair did not restore user data"), -- 94
					0 -- 94
				) -- 94
			end -- 94
			Content:save("/tmp/dora-mobile-lifecycle.result", "passed") -- 95
		end) -- 95
		if not ____try then -- 95
			____catch(____hasReturned) -- 95
		end -- 95
	end -- 95
	Content.writablePath = originalWritablePath -- 99
end) -- 28
return ____exports -- 28