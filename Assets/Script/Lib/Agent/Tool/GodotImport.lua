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
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
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
local function batchFailure(message) -- 32
	return { -- 33
		success = false, -- 33
		message = message, -- 33
		requestedCount = 0, -- 33
		importedCount = 0, -- 33
		skippedCount = 0, -- 33
		failedCount = 0, -- 33
		results = {} -- 33
	} -- 33
end -- 32
function ____exports.importGodotAssets(workDir, project, paths, force, isCancelled, settings) -- 36
	if force == nil then -- 36
		force = false -- 36
	end -- 36
	if isCancelled == nil then -- 36
		isCancelled = function() return false end -- 37
	end -- 37
	if settings == nil then -- 37
		settings = {} -- 37
	end -- 37
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 37
		local results = {} -- 38
		local function failed(path, message) -- 39
			return {success = false, path = path, status = "failed", message = message} -- 39
		end -- 39
		local directory = resolveWorkspaceDirectoryPath(workDir, project) -- 40
		local unavailable -- 41
		if type(_studio_agent_tool_begin) == "function" then -- 41
			unavailable = "Godot development is not supported in Dora Studio. Use desktop Dora." -- 42
		elseif App.platform ~= "Windows" and App.platform ~= "macOS" and App.platform ~= "Linux" then -- 42
			unavailable = "Embedded Godot asset importing is available on desktop only." -- 43
		elseif directory.success == false then -- 43
			unavailable = directory.message -- 44
		elseif not Content:exist(Path(directory.path, "project.godot")) then -- 44
			unavailable = "project must identify a Godot source project directory." -- 45
		elseif GodotNode == nil or type(GodotNode.importAssetAsync) ~= "function" then -- 45
			unavailable = "Rebuild Dora with the embedded Godot asset-import bridge." -- 46
		end -- 46
		if unavailable ~= nil or directory.success == false then -- 46
			return ____awaiter_resolve( -- 46
				nil, -- 46
				batchFailure(unavailable or "Invalid Godot project directory.") -- 47
			) -- 47
		end -- 47
		local projectSettings = Content:load(Path(directory.path, "project.godot")) or "" -- 48
		local version = string.match(projectSettings, "config_version%s*=%s*(%d+)") -- 49
		if version ~= "5" then -- 49
			return ____awaiter_resolve( -- 49
				nil, -- 49
				batchFailure("Only Godot 4 source projects are supported.") -- 50
			) -- 50
		end -- 50
		for ____, path in ipairs(paths) do -- 51
			do -- 51
				if isCancelled() then -- 51
					break -- 52
				end -- 52
				local file = resolveWorkspaceFilePath(workDir, path) -- 53
				local relative = file == nil and ".." or table.concat( -- 54
					__TS__StringSplit( -- 54
						Path:getRelative(file, directory.path), -- 54
						"\\" -- 54
					), -- 54
					"/" -- 54
				) -- 54
				if file == nil or relative == ".." or __TS__StringStartsWith(relative, "../") or Content:isAbsolutePath(relative) then -- 54
					results[#results + 1] = failed(path, "Asset path must be inside the selected project and workspace.") -- 56
					goto __continue12 -- 57
				end -- 57
				local result = __TS__Await(__TS__New( -- 59
					__TS__Promise, -- 59
					function(____, resolve) -- 59
						Director.systemScheduler:schedule(once(function() -- 60
							local result -- 61
							do -- 61
								local function ____catch(____error) -- 61
									resolve( -- 75
										nil, -- 75
										failed( -- 75
											path, -- 75
											tostring(____error) -- 75
										) -- 75
									) -- 75
								end -- 75
								local ____try, ____hasReturned, ____returnValue = pcall(function() -- 75
									local options = safeJsonEncode( -- 63
										__TS__ObjectAssign({force = force}, settings[path] ~= nil and ({settings = settings[path]}) or ({})), -- 63
										false, -- 63
										false -- 63
									) -- 63
									if not options then -- 63
										resolve( -- 64
											nil, -- 64
											failed(path, "Cannot encode asset import settings.") -- 64
										) -- 64
										return true -- 64
									end -- 64
									GodotNode:importAssetAsync( -- 65
										directory.path, -- 65
										file, -- 65
										options, -- 65
										function(available, text) -- 65
											if not available then -- 65
												result = failed(path, text) -- 66
												return -- 66
											end -- 66
											local decoded = safeJsonDecode(text) -- 67
											local value = decoded -- 68
											result = type(value) == "table" and type(value.success) == "boolean" and type(value.message) == "string" and (value.status == "imported" or value.status == "skipped" or value.status == "failed") and __TS__ObjectAssign({}, value, {path = path}) or failed(path, "Invalid response from embedded Godot importer.") -- 69
										end -- 65
									) -- 65
									while result == nil do -- 65
										sleep(0.02) -- 73
									end -- 73
									resolve(nil, result) -- 74
								end) -- 74
								if not ____try then -- 74
									____hasReturned, ____returnValue = ____catch(____hasReturned) -- 74
								end -- 74
								if ____hasReturned then -- 74
									return ____returnValue -- 62
								end -- 62
							end -- 62
						end)) -- 60
					end -- 59
				)) -- 59
				results[#results + 1] = result -- 78
			end -- 78
			::__continue12:: -- 78
		end -- 78
		return ____awaiter_resolve( -- 78
			nil, -- 78
			{ -- 80
				success = #results == #paths and __TS__ArrayEvery( -- 81
					results, -- 81
					function(____, result) return result.success end -- 81
				), -- 81
				cancelled = isCancelled(), -- 82
				requestedCount = #paths, -- 83
				importedCount = #__TS__ArrayFilter( -- 84
					results, -- 84
					function(____, result) return result.status == "imported" end -- 84
				), -- 84
				skippedCount = #__TS__ArrayFilter( -- 85
					results, -- 85
					function(____, result) return result.status == "skipped" end -- 85
				), -- 85
				failedCount = #__TS__ArrayFilter( -- 86
					results, -- 86
					function(____, result) return not result.success end -- 86
				), -- 86
				results = results -- 87
			} -- 87
		) -- 87
	end) -- 87
end -- 36
--- Synchronous Lua injection; yields the command coroutine while native work runs.
function ____exports.createGodotImportInjection(req) -- 92
	return function(options) -- 98
		local function complete(result) -- 99
			local encoded = safeJsonEncode(result) -- 100
			if encoded then -- 100
				req.print(encoded) -- 101
			end -- 101
			req.onResult(result) -- 102
			return result -- 103
		end -- 99
		if type(options) ~= "table" then -- 99
			return complete(batchFailure("importGodotAssets expects {project, paths, force?, settings?}.")) -- 105
		end -- 105
		local opts = options -- 106
		local project = type(opts.project) == "string" and __TS__StringTrim(opts.project) or "." -- 107
		local paths = opts.paths -- 108
		if project == "" or not __TS__ArrayIsArray(paths) or #paths < 1 or #paths > 64 or __TS__ArraySome( -- 108
			paths, -- 110
			function(____, path) return type(path) ~= "string" or __TS__StringTrim(path) == "" end -- 110
		) then -- 110
			return complete(batchFailure("Supply a project and 1 to 64 explicit workspace-relative asset paths.")) -- 111
		end -- 111
		if opts.force ~= nil and type(opts.force) ~= "boolean" then -- 111
			return complete(batchFailure("force must be boolean.")) -- 113
		end -- 113
		local settings = {} -- 114
		if opts.settings ~= nil then -- 114
			if type(opts.settings) ~= "table" then -- 114
				return complete(batchFailure("settings must map requested asset paths to setting objects.")) -- 116
			end -- 116
			local supplied = opts.settings -- 117
			for ____, path in ipairs(__TS__ObjectKeys(supplied)) do -- 118
				if not __TS__ArrayIncludes(paths, path) or type(supplied[path]) ~= "table" then -- 118
					return complete(batchFailure("Each settings key must be an exact path in paths, with a setting object.")) -- 119
				end -- 119
				local values = supplied[path] -- 120
				for ____, key in ipairs(__TS__ObjectKeys(values)) do -- 121
					local value = values[key] -- 122
					if key == "mipmaps" or key == "loop" then -- 122
						if type(value) ~= "boolean" then -- 122
							return complete(batchFailure(key .. " must be boolean.")) -- 124
						end -- 124
					elseif key == "loopOffsetSeconds" then -- 124
						if type(value) ~= "number" or not __TS__NumberIsFinite(value) or value < 0 then -- 124
							return complete(batchFailure("loopOffsetSeconds must be a finite non-negative number.")) -- 126
						end -- 126
					else -- 126
						return complete(batchFailure(("Unknown import setting: " .. key) .. ".")) -- 127
					end -- 127
				end -- 127
				settings[path] = values -- 129
			end -- 129
		end -- 129
		local result -- 132
		local ____self_0 = ____exports.importGodotAssets( -- 132
			req.workDir, -- 133
			project, -- 133
			paths, -- 133
			opts.force == true, -- 133
			function() return req:isCancelled() end, -- 133
			settings -- 133
		) -- 133
		____self_0["then"]( -- 133
			____self_0, -- 133
			function(____, value) -- 134
				result = value -- 134
			end, -- 134
			function(____, ____error) -- 134
				result = batchFailure(tostring(____error)) -- 134
			end -- 134
		) -- 134
		while result == nil do -- 134
			sleep() -- 135
		end -- 135
		return complete(result) -- 136
	end -- 98
end -- 92
return ____exports -- 92