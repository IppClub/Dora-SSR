-- [ts]: GodotScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
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
local ____GodotBuild = require("Agent.Tool.GodotBuild") -- 5
local findGodotProject = ____GodotBuild.findGodotProject -- 5
local function inspect(workDir, options, isCancelled) -- 23
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 23
		local path = type(options.path) == "string" and __TS__StringTrim(options.path) or "" -- 24
		local function failure(message) -- 25
			return {success = false, path = path, message = message} -- 25
		end -- 25
		if type(_studio_agent_tool_begin) == "function" then -- 25
			return ____awaiter_resolve( -- 25
				nil, -- 25
				failure("Godot development is not supported in Dora Studio. Use desktop Dora.") -- 26
			) -- 26
		end -- 26
		if isCancelled() then -- 26
			return ____awaiter_resolve( -- 26
				nil, -- 26
				failure("Static scene inspection cancelled.") -- 27
			) -- 27
		end -- 27
		local file = resolveWorkspaceFilePath(workDir, path) -- 28
		if file == nil or not Content:exist(file) or Content:isdir(file) then -- 28
			return ____awaiter_resolve( -- 28
				nil, -- 28
				failure("path must identify an existing workspace-relative .tscn file.") -- 29
			) -- 29
		end -- 29
		if string.lower(Path:getExt(file)) ~= "tscn" then -- 29
			return ____awaiter_resolve( -- 29
				nil, -- 29
				failure("Static inspection supports .tscn text scenes; binary .scn is not supported.") -- 30
			) -- 30
		end -- 30
		local project -- 31
		if options.project ~= nil then -- 31
			if type(options.project) ~= "string" then -- 31
				return ____awaiter_resolve( -- 31
					nil, -- 31
					failure("project must be a workspace-relative directory.") -- 33
				) -- 33
			end -- 33
			local directory = resolveWorkspaceDirectoryPath(workDir, options.project) -- 34
			if directory.success == false then -- 34
				return ____awaiter_resolve( -- 34
					nil, -- 34
					failure(directory.message) -- 35
				) -- 35
			end -- 35
			project = directory.path -- 36
		else -- 36
			project = findGodotProject(workDir, file) -- 37
		end -- 37
		if project == nil or not Content:exist(Path(project, "project.godot")) then -- 37
			return ____awaiter_resolve( -- 37
				nil, -- 37
				failure("No enclosing Godot source project was found.") -- 38
			) -- 38
		end -- 38
		local relative = table.concat( -- 39
			__TS__StringSplit( -- 39
				Path:getRelative(file, project), -- 39
				"\\" -- 39
			), -- 39
			"/" -- 39
		) -- 39
		if relative == ".." or __TS__StringStartsWith(relative, "../") or Content:isAbsolutePath(relative) then -- 39
			return ____awaiter_resolve( -- 39
				nil, -- 39
				failure("Scene must be inside the selected Godot project.") -- 40
			) -- 40
		end -- 40
		local version = string.match( -- 41
			Content:load(Path(project, "project.godot")) or "", -- 41
			"config_version%s*=%s*(%d+)" -- 41
		) -- 41
		if version ~= "5" then -- 41
			return ____awaiter_resolve( -- 41
				nil, -- 41
				failure("Only Godot 4 source projects are supported.") -- 42
			) -- 42
		end -- 42
		if GodotNode == nil or type(GodotNode.inspectSceneAsync) ~= "function" then -- 42
			return ____awaiter_resolve( -- 42
				nil, -- 42
				failure("Rebuild Dora with the bundled static scene inspection bridge.") -- 43
			) -- 43
		end -- 43
		local query = {maxNodes = 128, maxProperties = 64} -- 44
		for ____, key in ipairs({"maxNodes", "maxProperties"}) do -- 45
			local value = options[key] -- 46
			local minimum = key == "maxNodes" and 1 or 0 -- 47
			local maximum = key == "maxNodes" and 512 or 128 -- 47
			if value ~= nil and (type(value) ~= "number" or not __TS__NumberIsFinite(value) or math.floor(value) ~= value or value < minimum or value > maximum) then -- 47
				return ____awaiter_resolve( -- 47
					nil, -- 47
					failure(((((key .. " must be an integer from ") .. tostring(minimum)) .. " to ") .. tostring(maximum)) .. ".") -- 48
				) -- 48
			end -- 48
			if value ~= nil then -- 48
				query[key] = value -- 49
			end -- 49
		end -- 49
		if options.nodePath ~= nil then -- 49
			if type(options.nodePath) ~= "string" then -- 49
				return ____awaiter_resolve( -- 49
					nil, -- 49
					failure("nodePath must be a scene-relative node path.") -- 52
				) -- 52
			end -- 52
			query.nodePath = options.nodePath -- 53
		end -- 53
		local resolvedProject = project -- 55
		local encoded = safeJsonEncode(query) -- 56
		if not encoded then -- 56
			return ____awaiter_resolve( -- 56
				nil, -- 56
				failure("Cannot encode scene inspection options.") -- 57
			) -- 57
		end -- 57
		return ____awaiter_resolve( -- 57
			nil, -- 57
			__TS__New( -- 58
				__TS__Promise, -- 58
				function(____, resolve) -- 58
					Director.systemScheduler:schedule(once(function() -- 59
						if isCancelled() then -- 59
							resolve( -- 60
								nil, -- 60
								failure("Static scene inspection cancelled.") -- 60
							) -- 60
							return -- 60
						end -- 60
						local result -- 61
						do -- 61
							local function ____catch(____error) -- 61
								resolve( -- 73
									nil, -- 73
									failure(tostring(____error)) -- 73
								) -- 73
							end -- 73
							local ____try, ____hasReturned = pcall(function() -- 73
								GodotNode:inspectSceneAsync( -- 63
									resolvedProject, -- 63
									file, -- 63
									encoded, -- 63
									function(available, text) -- 63
										if not available then -- 63
											result = failure(text) -- 64
											return -- 64
										end -- 64
										local decoded = safeJsonDecode(text) -- 65
										local value = decoded -- 66
										local ____temp_1 = type(value) == "table" and type(value.success) == "boolean" -- 67
										if ____temp_1 then -- 67
											local ____value_success_0 -- 68
											if value.success then -- 68
												____value_success_0 = __TS__ArrayIsArray(value.nodes) and __TS__ArrayIsArray(value.resources) and __TS__ArrayIsArray(value.connections) -- 68
											else -- 68
												____value_success_0 = type(value.message) == "string" -- 68
											end -- 68
											____temp_1 = ____value_success_0 -- 67
										end -- 67
										result = ____temp_1 and __TS__ObjectAssign({}, value, {path = path}) or failure("Invalid response from bundled Godot scene inspector.") -- 67
									end -- 63
								) -- 63
								while result == nil do -- 63
									sleep(0.02) -- 71
								end -- 71
								resolve( -- 72
									nil, -- 72
									isCancelled() and failure("Static scene inspection cancelled.") or result -- 72
								) -- 72
							end) -- 72
							if not ____try then -- 72
								____catch(____hasReturned) -- 72
							end -- 72
						end -- 72
					end)) -- 59
				end -- 58
			) -- 58
		) -- 58
	end) -- 58
end -- 23
function ____exports.createGodotSceneInjection(req) -- 78
	return function(options) -- 84
		local result -- 85
		if type(options) ~= "table" then -- 85
			result = {success = false, message = "inspectGodotScene expects {path, project?, nodePath?, maxNodes?, maxProperties?}."} -- 86
		else -- 86
			local ____self_2 = inspect( -- 86
				req.workDir, -- 87
				options, -- 87
				function() return req.isCancelled() end -- 87
			) -- 87
			____self_2["then"]( -- 87
				____self_2, -- 87
				function(____, value) -- 87
					result = value -- 87
				end, -- 87
				function(____, ____error) -- 87
					result = { -- 87
						success = false, -- 87
						message = tostring(____error) -- 87
					} -- 87
				end -- 87
			) -- 87
		end -- 87
		while result == nil do -- 87
			sleep() -- 88
		end -- 88
		local encoded = safeJsonEncode(result) -- 89
		if encoded then -- 89
			req.print(encoded) -- 90
		end -- 90
		req.onResult(result) -- 91
		return result -- 92
	end -- 84
end -- 78
return ____exports -- 78