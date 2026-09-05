-- [ts]: PackagePanelTest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 2
local startPackagePanel = ____PackagePanel.startPackagePanel -- 2
thread(function() -- 5
	local marker = Path(Content.appPath, "mobile-package-panel-test.result") -- 6
	local root = Path( -- 7
		Content.writablePath, -- 7
		".package-panel-test-" .. tostring(App.rand) -- 7
	) -- 7
	local host -- 8
	Content:save(marker, "running") -- 9
	do -- 9
		local function ____catch(e) -- 9
			Content:save( -- 42
				marker, -- 42
				"failed: " .. tostring(e) -- 42
			) -- 42
		end -- 42
		local ____try, ____hasReturned = pcall(function() -- 42
			assert(Content:mkdir(root)) -- 11
			Content:save( -- 12
				Path(root, "init.lua"), -- 12
				"return true" -- 12
			) -- 12
			host = startPackagePanel({ -- 13
				mode = "share", -- 13
				entry = {title = "Panel test", workDir = root}, -- 13
				onClosed = function() -- 13
				end -- 13
			}) -- 13
			local function sheet() -- 14
				local found -- 15
				host:traverse(function(node) -- 16
					if node.tag == "mobile-package-sheet" then -- 16
						found = node -- 16
					end -- 16
					return false -- 16
				end) -- 16
				return found -- 17
			end -- 14
			local ____opt_0 = Director.entry.children -- 14
			local sceneChildren = ____opt_0 and ____opt_0.count or 0 -- 19
			local initial = sheet() -- 20
			assert(initial) -- 21
			local height = initial.height -- 22
			local ready = false -- 23
			do -- 23
				local frame = 0 -- 24
				while frame < 180 do -- 24
					sleep() -- 25
					local ____assert_4 = assert -- 26
					local ____opt_2 = Director.entry.children -- 26
					____assert_4((____opt_2 and ____opt_2.count or 0) == sceneChildren, "measurement labels leaked into the scene") -- 26
					assert( -- 27
						sheet() == initial, -- 27
						"export replaced the visible sheet" -- 27
					) -- 27
					assert( -- 28
						sheet().height == height, -- 28
						"export changed the sheet height" -- 28
					) -- 28
					host:traverse(function(node) -- 29
						local text = node.tag == "mobile-package-detail" and node.text or nil -- 30
						if type(text) == "string" and (string.find(text, " MB", nil, true) or 0) - 1 >= 0 then -- 30
							ready = true -- 31
						end -- 31
						return false -- 32
					end) -- 29
					if ready and frame >= 30 then -- 29
						break -- 34
					end -- 34
					frame = frame + 1 -- 24
				end -- 24
			end -- 24
			assert(ready, "export never completed") -- 36
			host:removeFromParent(true) -- 37
			host = nil -- 38
			sleep() -- 39
			local ____assert_7 = assert -- 40
			local ____opt_5 = Director.entry.children -- 40
			____assert_7((____opt_5 and ____opt_5.count or 0) == sceneChildren, "closing the sheet left scene nodes behind") -- 40
			Content:save(marker, "passed: stable sheet and no measurement nodes during export or after close") -- 41
		end) -- 41
		if not ____try then -- 41
			____catch(____hasReturned) -- 41
		end -- 41
		do -- 41
			if host ~= nil then -- 41
				host:removeFromParent(true) -- 43
			end -- 43
			Content:remove(root) -- 43
		end -- 43
	end -- 43
end) -- 5
return ____exports -- 5