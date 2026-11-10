-- [ts]: GodotImport.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local GodotNode = ____Dora.GodotNode -- 2
local Path = ____Dora.Path -- 2
local once = ____Dora.once -- 2
local sleep = ____Dora.sleep -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____Workspace = require("Agent.Tool.Workspace") -- 4
local resolveWorkspaceDirectoryPath = ____Workspace.resolveWorkspaceDirectoryPath -- 4
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 4
local function batchFailure(message) -- 26
	return { -- 27
		success = false, -- 27
		message = message, -- 27
		requestedCount = 0, -- 27
		importedCount = 0, -- 27
		skippedCount = 0, -- 27
		failedCount = 0, -- 27
		results = {} -- 27
	} -- 27
end -- 26
function ____exports.importGodotAssets(workDir, project, paths, force, isCancelled) -- 30
	if force == nil then -- 30
		force = false -- 30
	end -- 30
	if isCancelled == nil then -- 30
		isCancelled = function() return false end -- 31
	end -- 31
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 31
		local results = {} -- 32
		local function failed(path, message) -- 33
			return {success = false, path = path, status = "failed", message = message} -- 33
		end -- 33
		local directory = resolveWorkspaceDirectoryPath(workDir, project) -- 34
		local unavailable -- 35
		if type(_studio_agent_tool_begin) == "function" then -- 35
			unavailable = "Godot development is not supported in Dora Studio. Use desktop Dora." -- 36
		elseif App.platform ~= "Windows" and App.platform ~= "macOS" and App.platform ~= "Linux" then -- 36
			unavailable = "Embedded Godot asset importing is available on desktop only." -- 37
		elseif directory.success == false then -- 37
			unavailable = directory.message -- 38
		elseif not Content:exist(Path(directory.path, "project.godot")) then -- 38
			unavailable = "project must identify a Godot source project directory." -- 39
		elseif GodotNode == nil or type(GodotNode.importAssetAsync) ~= "function" then -- 39
			unavailable = "Rebuild Dora with the embedded Godot asset-import bridge." -- 40
		end -- 40
		if unavailable ~= nil or directory.success == false then -- 40
			return ____awaiter_resolve( -- 40
				nil, -- 40
				batchFailure(unavailable or "Invalid Godot project directory.") -- 41
			) -- 41
		end -- 41
		local settings = Content:load(Path(directory.path, "project.godot")) or "" -- 42
		local version = string.match(settings, "config_version%s*=%s*(%d+)") -- 43
		if version ~= "5" then -- 43
			return ____awaiter_resolve( -- 43
				nil, -- 43
				batchFailure("Only Godot 4 source projects are supported.") -- 44
			) -- 44
		end -- 44
		for ____, path in ipairs(paths) do -- 45
			do -- 45
				if isCancelled() then -- 45
					break -- 46
				end -- 46
				local file = resolveWorkspaceFilePath(workDir, path) -- 47
				local relative = file == nil and ".." or table.concat( -- 48
					__TS__StringSplit( -- 48
						Path:getRelative(file, directory.path), -- 48
						"\\" -- 48
					), -- 48
					"/" -- 48
				) -- 48
				if file == nil or relative == ".." or __TS__StringStartsWith(relative, "../") or Content:isAbsolutePath(relative) then -- 48
					results[#results + 1] = failed(path, "Asset path must be inside the selected project and workspace.") -- 50
					goto __continue12 -- 51
				end -- 51
				local result = __TS__Await(__TS__New( -- 53
					__TS__Promise, -- 53
					function(____, resolve) -- 53
						Director.systemScheduler:schedule(once(function() -- 54
							local result -- 55
							do -- 55
								local function ____catch(____error) -- 55
									resolve( -- 67
										nil, -- 67
										failed( -- 67
											path, -- 67
											tostring(____error) -- 67
										) -- 67
									) -- 67
								end -- 67
								local ____try, ____hasReturned = pcall(function() -- 67
									GodotNode:importAssetAsync( -- 57
										directory.path, -- 57
										file, -- 57
										force and "{\"force\":true}" or "{}", -- 57
										function(available, text) -- 57
											if not available then -- 57
												result = failed(path, text) -- 58
												return -- 58
											end -- 58
											local decoded = safeJsonDecode(text) -- 59
											local value = decoded -- 60
											result = type(value) == "table" and type(value.success) == "boolean" and type(value.message) == "string" and (value.status == "imported" or value.status == "skipped" or value.status == "failed") and __TS__ObjectAssign({}, value, {path = path}) or failed(path, "Invalid response from embedded Godot importer.") -- 61
										end -- 57
									) -- 57
									while result == nil do -- 57
										sleep(0.02) -- 65
									end -- 65
									resolve(nil, result) -- 66
								end) -- 66
								if not ____try then -- 66
									____catch(____hasReturned) -- 66
								end -- 66
							end -- 66
						end)) -- 54
					end -- 53
				)) -- 53
				results[#results + 1] = result -- 70
			end -- 70
			::__continue12:: -- 70
		end -- 70
		return ____awaiter_resolve( -- 70
			nil, -- 70
			{ -- 72
				success = #results == #paths and __TS__ArrayEvery( -- 73
					results, -- 73
					function(____, result) return result.success end -- 73
				), -- 73
				cancelled = isCancelled(), -- 74
				requestedCount = #paths, -- 75
				importedCount = #__TS__ArrayFilter( -- 76
					results, -- 76
					function(____, result) return result.status == "imported" end -- 76
				), -- 76
				skippedCount = #__TS__ArrayFilter( -- 77
					results, -- 77
					function(____, result) return result.status == "skipped" end -- 77
				), -- 77
				failedCount = #__TS__ArrayFilter( -- 78
					results, -- 78
					function(____, result) return not result.success end -- 78
				), -- 78
				results = results -- 79
			} -- 79
		) -- 79
	end) -- 79
end -- 30
--- Synchronous Lua injection; yields the command coroutine while native work runs.
function ____exports.createGodotImportInjection(req) -- 84
	return function(options) -- 90
		local function complete(result) -- 91
			local encoded = safeJsonEncode(result) -- 92
			if encoded then -- 92
				req.print(encoded) -- 93
			end -- 93
			req.onResult(result) -- 94
			return result -- 95
		end -- 91
		if type(options) ~= "table" then -- 91
			return complete(batchFailure("importGodotAssets expects {project, paths, force?}.")) -- 97
		end -- 97
		local opts = options -- 98
		local project = type(opts.project) == "string" and __TS__StringTrim(opts.project) or "." -- 99
		local paths = opts.paths -- 100
		if project == "" or not __TS__ArrayIsArray(paths) or #paths < 1 or #paths > 64 or __TS__ArraySome( -- 100
			paths, -- 102
			function(____, path) return type(path) ~= "string" or __TS__StringTrim(path) == "" end -- 102
		) then -- 102
			return complete(batchFailure("Supply a project and 1 to 64 explicit workspace-relative asset paths.")) -- 103
		end -- 103
		if opts.force ~= nil and type(opts.force) ~= "boolean" then -- 103
			return complete(batchFailure("force must be boolean.")) -- 105
		end -- 105
		local result -- 106
		local ____self_0 = ____exports.importGodotAssets( -- 106
			req.workDir, -- 107
			project, -- 107
			paths, -- 107
			opts.force == true, -- 107
			function() return req:isCancelled() end -- 107
		) -- 107
		____self_0["then"]( -- 107
			____self_0, -- 107
			function(____, value) -- 108
				result = value -- 108
			end, -- 108
			function(____, ____error) -- 108
				result = batchFailure(tostring(____error)) -- 108
			end -- 108
		) -- 108
		while result == nil do -- 108
			sleep() -- 109
		end -- 109
		return complete(result) -- 110
	end -- 90
end -- 84
return ____exports -- 84