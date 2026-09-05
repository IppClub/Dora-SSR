-- [ts]: PackageTest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local thread = ____Dora.thread -- 1
local ____Package = require("Dev.Mobile.Package") -- 2
local discardPackage = ____Package.discardPackage -- 2
local exportPackage = ____Package.exportPackage -- 2
local inspectPackage = ____Package.inspectPackage -- 2
local installPackage = ____Package.installPackage -- 2
thread(function() -- 5
	local marker = Path(Content.appPath, "mobile-package-test.result") -- 6
	local fixtures = Path(Content.appPath, "mobile-package-fixtures") -- 7
	local root = Path( -- 8
		Content.writablePath, -- 8
		".package-test-" .. tostring(App.rand) -- 8
	) -- 8
	local installed = {} -- 9
	local temporary = {root} -- 10
	Content:save(marker, "running") -- 11
	do -- 11
		local function ____catch(e) -- 11
			Content:save( -- 57
				marker, -- 57
				"failed: " .. tostring(e) -- 57
			) -- 57
		end -- 57
		local ____try, ____hasReturned = pcall(function() -- 57
			assert(Content:mkdir(root)) -- 13
			Content:mkdir(Path(root, ".agent")) -- 14
			Content:mkdir(Path(root, "Image")) -- 15
			Content:save( -- 16
				Path(root, "init.lua"), -- 16
				"return 'package-played'" -- 16
			) -- 16
			Content:save( -- 17
				Path(root, "init.ts"), -- 17
				"// editable source" -- 17
			) -- 17
			Content:save( -- 18
				Path(root, "Image", "data.txt"), -- 18
				"asset-data" -- 18
			) -- 18
			Content:save( -- 19
				Path(root, ".env"), -- 19
				"private-test-value" -- 19
			) -- 19
			Content:save( -- 20
				Path(root, ".agent", "history.json"), -- 20
				"private-test-history" -- 20
			) -- 20
			local title = "分享回归-" .. tostring(App.rand) -- 21
			local exported = exportPackage({title = title, workDir = root}) -- 22
			temporary[#temporary + 1] = Path:getPath(exported.path) -- 23
			Content:copy( -- 24
				exported.path, -- 24
				Path(fixtures, "roundtrip.zip") -- 24
			) -- 24
			Content:save( -- 25
				Path(root, "init.lua"), -- 25
				"return 'edited-later'" -- 25
			) -- 25
			local preview = inspectPackage(exported.path) -- 26
			temporary[#temporary + 1] = preview.stage -- 27
			assert(preview.title == title, "Unicode title round trip") -- 28
			assert( -- 29
				Content:load(Path(preview.root, "init.lua")) == "return 'package-played'", -- 29
				"immutable export snapshot" -- 29
			) -- 29
			assert( -- 30
				Content:exist(Path(preview.root, "init.ts")), -- 30
				"editable source preserved" -- 30
			) -- 30
			assert( -- 31
				Content:load(Path(preview.root, "Image", "data.txt")) == "asset-data", -- 31
				"assets preserved" -- 31
			) -- 31
			assert( -- 32
				not Content:exist(Path(preview.root, ".env")) and not Content:exist(Path(preview.root, ".agent")), -- 32
				"private state excluded" -- 32
			) -- 32
			local first = installPackage(preview) -- 33
			installed[#installed + 1] = first.workDir -- 34
			assert( -- 35
				dofile(Path(first.workDir, "init.lua")) == "package-played", -- 35
				"installed entry runs" -- 35
			) -- 35
			local second = installPackage(inspectPackage(exported.path)) -- 36
			installed[#installed + 1] = second.workDir -- 37
			assert(first.workDir ~= second.workDir, "same-name import creates a copy") -- 38
			assert( -- 39
				Content:load(Path(first.workDir, "init.lua")) == "return 'package-played'", -- 39
				"original is unchanged" -- 39
			) -- 39
			local cancelled = inspectPackage(exported.path) -- 40
			discardPackage(cancelled) -- 41
			assert( -- 42
				not Content:exist(cancelled.stage), -- 42
				"cancel cleans staging" -- 42
			) -- 42
			for ____, name in ipairs({ -- 43
				"traversal", -- 43
				"absolute", -- 43
				"backslash", -- 43
				"drive", -- 43
				"oversize", -- 43
				"too-many", -- 43
				"corrupt", -- 43
				"missing-init", -- 43
				"bad-metadata", -- 43
				"future-version" -- 43
			}) do -- 43
				local rejected = false -- 44
				do -- 44
					local function ____catch(_) -- 44
						rejected = true -- 46
					end -- 46
					local ____try, ____hasReturned = pcall(function() -- 46
						local unexpected = inspectPackage(Path(fixtures, name .. ".zip")) -- 45
						discardPackage(unexpected) -- 45
					end) -- 45
					if not ____try then -- 45
						____catch(____hasReturned) -- 45
					end -- 45
				end -- 45
				assert(rejected, "reject " .. name) -- 47
			end -- 47
			local legacy = inspectPackage(Path(fixtures, "legacy.zip")) -- 49
			assert( -- 50
				Content:exist(Path(legacy.root, "init.lua")), -- 50
				"legacy wrapper ZIP" -- 50
			) -- 50
			discardPackage(legacy) -- 51
			local mixed = Path(root, "mixed") -- 52
			assert( -- 53
				Content:unzipAsync( -- 53
					Path(fixtures, "mixed.zip"), -- 53
					mixed -- 53
				), -- 53
				"root files coexist with a same-named folder" -- 53
			) -- 53
			assert( -- 54
				Content:exist(Path(mixed, "init.lua")) and Content:exist(Path(mixed, "mixed", "asset.txt")), -- 54
				"root stripping stays inside destination" -- 54
			) -- 54
			Content:save(marker, "passed: snapshot, source/assets, private-state exclusion, unicode, collision, cancel, 10 invalid packages, legacy ZIP, mixed-root ZIP") -- 55
		end) -- 55
		if not ____try then -- 55
			____catch(____hasReturned) -- 55
		end -- 55
		do -- 55
			for ____, path in ipairs(installed) do -- 59
				Content:remove(path) -- 59
			end -- 59
			for ____, path in ipairs(temporary) do -- 60
				Content:remove(path) -- 60
			end -- 60
		end -- 60
	end -- 60
end) -- 5
return ____exports -- 5