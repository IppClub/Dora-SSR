-- [ts]: GodotRuntimeScene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local function inspect(workDir, options, isCancelled) -- 18
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 18
		local function failure(message) -- 19
			return {success = false, message = message} -- 19
		end -- 19
		if type(_studio_agent_tool_begin) == "function" then -- 19
			return ____awaiter_resolve( -- 19
				nil, -- 19
				failure("Godot development is not supported in Dora Studio. Use desktop Dora.") -- 20
			) -- 20
		end -- 20
		if isCancelled() then -- 20
			return ____awaiter_resolve( -- 20
				nil, -- 20
				failure("Live scene inspection cancelled.") -- 21
			) -- 21
		end -- 21
		for ____, key in ipairs(__TS__ObjectKeys(options)) do -- 22
			if not __TS__ArrayIncludes({ -- 22
				"project", -- 22
				"nodePath", -- 22
				"nodeType", -- 22
				"maxNodes", -- 22
				"properties" -- 22
			}, key) then -- 22
				return ____awaiter_resolve( -- 22
					nil, -- 22
					failure("Unknown live scene option: " .. key) -- 22
				) -- 22
			end -- 22
		end -- 22
		if options.project ~= nil and type(options.project) ~= "string" then -- 22
			return ____awaiter_resolve( -- 22
				nil, -- 22
				failure("project must be a workspace-relative directory.") -- 23
			) -- 23
		end -- 23
		local directory = resolveWorkspaceDirectoryPath(workDir, options.project or ".") -- 24
		if directory.success == false then -- 24
			return ____awaiter_resolve( -- 24
				nil, -- 24
				failure(directory.message) -- 25
			) -- 25
		end -- 25
		if not Content:exist(Path(directory.path, "project.godot")) then -- 25
			return ____awaiter_resolve( -- 25
				nil, -- 25
				failure("project must identify a Godot source project directory.") -- 26
			) -- 26
		end -- 26
		if GodotNode == nil or type(GodotNode.inspectRuntimeSceneAsync) ~= "function" then -- 26
			return ____awaiter_resolve( -- 26
				nil, -- 26
				failure("Rebuild Dora with the bundled live scene inspection bridge.") -- 27
			) -- 27
		end -- 27
		local query = {nodePath = ".", maxNodes = 128} -- 28
		if options.nodePath ~= nil then -- 28
			if type(options.nodePath) ~= "string" or #options.nodePath > 1024 then -- 28
				return ____awaiter_resolve( -- 28
					nil, -- 28
					failure("nodePath must be a relative path of at most 1024 characters.") -- 30
				) -- 30
			end -- 30
			query.nodePath = options.nodePath -- 31
		end -- 31
		if options.nodeType ~= nil then -- 31
			if type(options.nodeType) ~= "string" or #options.nodeType < 1 or #options.nodeType > 64 then -- 31
				return ____awaiter_resolve( -- 31
					nil, -- 31
					failure("nodeType must be an exact native class name of 1 to 64 characters.") -- 34
				) -- 34
			end -- 34
			query.nodeType = options.nodeType -- 35
		end -- 35
		if options.maxNodes ~= nil then -- 35
			local n = options.maxNodes -- 38
			if type(n) ~= "number" or not __TS__NumberIsFinite(n) or math.floor(n) ~= n or n < 1 or n > 256 then -- 38
				return ____awaiter_resolve( -- 38
					nil, -- 38
					failure("maxNodes must be an integer from 1 to 256.") -- 39
				) -- 39
			end -- 39
			query.maxNodes = n -- 40
		end -- 40
		if options.properties ~= nil then -- 40
			local names = options.properties -- 43
			if not __TS__ArrayIsArray(names) or #names > 32 or __TS__ArraySome( -- 43
				names, -- 44
				function(____, name) return type(name) ~= "string" or #name < 1 or #name > 128 end -- 44
			) then -- 44
				return ____awaiter_resolve( -- 44
					nil, -- 44
					failure("properties must contain at most 32 property names of 1 to 128 characters.") -- 44
				) -- 44
			end -- 44
			query.properties = names -- 45
		end -- 45
		local encoded = safeJsonEncode(query) -- 47
		if not encoded or #encoded > 8192 then -- 47
			return ____awaiter_resolve( -- 47
				nil, -- 47
				failure("Live scene query exceeds 8 KiB.") -- 48
			) -- 48
		end -- 48
		return ____awaiter_resolve( -- 48
			nil, -- 48
			__TS__New( -- 49
				__TS__Promise, -- 49
				function(____, resolve) -- 49
					Director.systemScheduler:schedule(once(function() -- 50
						if isCancelled() then -- 50
							resolve( -- 51
								nil, -- 51
								failure("Live scene inspection cancelled.") -- 51
							) -- 51
							return -- 51
						end -- 51
						local result -- 52
						do -- 52
							local function ____catch(____error) -- 52
								resolve( -- 65
									nil, -- 65
									failure(tostring(____error)) -- 65
								) -- 65
							end -- 65
							local ____try, ____hasReturned = pcall(function() -- 65
								GodotNode:inspectRuntimeSceneAsync( -- 54
									directory.path, -- 54
									encoded, -- 54
									function(available, text) -- 54
										if not available then -- 54
											result = failure(text) -- 55
											return -- 55
										end -- 55
										if #text > 128 * 1024 then -- 55
											result = failure("Live scene response exceeds 128 KiB.") -- 56
											return -- 56
										end -- 56
										local decoded = safeJsonDecode(text) -- 57
										local value = decoded -- 58
										local ____temp_1 = type(value) == "table" and type(value.success) == "boolean" -- 59
										if ____temp_1 then -- 59
											local ____value_success_0 -- 60
											if value.success then -- 60
												____value_success_0 = __TS__ArrayIsArray(value.nodes) -- 60
											else -- 60
												____value_success_0 = type(value.message) == "string" -- 60
											end -- 60
											____temp_1 = ____value_success_0 -- 59
										end -- 59
										result = ____temp_1 and value or failure("Invalid response from bundled live scene inspector.") -- 59
									end -- 54
								) -- 54
								while result == nil do -- 54
									sleep(0.02) -- 63
								end -- 63
								resolve( -- 64
									nil, -- 64
									isCancelled() and failure("Live scene inspection cancelled.") or result -- 64
								) -- 64
							end) -- 64
							if not ____try then -- 64
								____catch(____hasReturned) -- 64
							end -- 64
						end -- 64
					end)) -- 50
				end -- 49
			) -- 49
		) -- 49
	end) -- 49
end -- 18
function ____exports.createGodotRuntimeSceneInjection(req) -- 69
	return function(options) -- 75
		local result -- 76
		if options ~= nil and type(options) ~= "table" then -- 76
			result = {success = false, message = "inspectGodotRuntimeScene expects {project?, nodePath?, nodeType?, maxNodes?, properties?}."} -- 77
		else -- 77
			local ____self_2 = inspect( -- 77
				req.workDir, -- 78
				options or ({}), -- 78
				function() return req.isCancelled() end -- 78
			) -- 78
			____self_2["then"]( -- 78
				____self_2, -- 78
				function(____, value) -- 78
					result = value -- 78
				end, -- 78
				function(____, ____error) -- 78
					result = { -- 78
						success = false, -- 78
						message = tostring(____error) -- 78
					} -- 78
				end -- 78
			) -- 78
		end -- 78
		while result == nil do -- 78
			sleep() -- 79
		end -- 79
		local encoded = safeJsonEncode(result) -- 80
		if encoded then -- 80
			req.print(encoded) -- 81
		end -- 81
		req.onResult(result) -- 82
		return result -- 83
	end -- 75
end -- 69
return ____exports -- 69