-- [ts]: GodotCheck.ts
local ____lualib = require("lualib_bundle") -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local pending = __TS__New(Map) -- 12
local active = __TS__New(Set) -- 13
local sequence = 0 -- 14
function ____exports.checkGodotFile(project, file, content, coalesce) -- 19
	if coalesce == nil then -- 19
		coalesce = true -- 19
	end -- 19
	local function failure(message) -- 20
		return {success = false, info = {{ -- 20
			"tool", -- 20
			file, -- 20
			1, -- 20
			0, -- 20
			message -- 20
		}}} -- 20
	end -- 20
	if type(_studio_agent_tool_begin) == "function" then -- 20
		return __TS__Promise.resolve(failure("Godot game development is not supported in Dora Studio. Use the desktop Dora Web IDE.")) -- 21
	end -- 21
	project = Path:getPath(Path(project, "project.godot")) -- 22
	file = Path(file, "") -- 23
	local relative = table.concat( -- 24
		__TS__StringSplit( -- 24
			Path:getRelative(file, project), -- 24
			"\\" -- 24
		), -- 24
		"/" -- 24
	) -- 24
	if relative == "" or relative == "." or relative == ".." or __TS__StringStartsWith(relative, "../") or Content:isAbsolutePath(relative) then -- 24
		return __TS__Promise.resolve(failure("Godot check target is outside the project.")) -- 26
	end -- 26
	local settings = Content:load(Path(project, "project.godot")) or "" -- 27
	local format = string.match(settings, "config_version%s*=%s*(%d+)") -- 28
	if format ~= "5" then -- 28
		return __TS__Promise.resolve(failure("Embedded checks require a Godot 4 project (config_version=5).")) -- 29
	end -- 29
	if __TS__ArraySome( -- 29
		__TS__StringSplit(settings, "\n"), -- 30
		function(____, line) return __TS__StringStartsWith( -- 30
			__TS__StringTrim(line), -- 30
			"config/features" -- 30
		) and __TS__StringIncludes(line, "\"C#\"") end -- 30
	) or #Content:glob(project, {"**/*.gdextension", "!**/.*/**", "!**/node_modules/**"}) > 0 then -- 30
		return __TS__Promise.resolve(failure("Embedded checks do not load Godot C#/Mono or native GDExtension sidecars.")) -- 32
	end -- 32
	if GodotNode == nil or type(GodotNode.checkCodeAsync) ~= "function" then -- 32
		return __TS__Promise.resolve(failure("This Dora host has no embedded Godot compiler API; rebuild Dora.")) -- 33
	end -- 33
	sequence = sequence + 1 -- 34
	local id = sequence -- 34
	if coalesce then -- 34
		pending:set(project, id) -- 35
	end -- 35
	local function cancelled() -- 36
		return coalesce and pending:get(project) ~= id -- 36
	end -- 36
	return __TS__New( -- 37
		__TS__Promise, -- 37
		function(____, resolve) -- 37
			Director.systemScheduler:schedule(once(function() -- 38
				while active:has(project) and not cancelled() do -- 38
					sleep(0.02) -- 39
				end -- 39
				if cancelled() then -- 39
					resolve(nil, {success = true, skipped = true}) -- 40
					return -- 40
				end -- 40
				active:add(project) -- 41
				do -- 41
					local function ____catch(____error) -- 41
						resolve( -- 54
							nil, -- 54
							cancelled() and ({success = true, skipped = true}) or failure(tostring(____error)) -- 54
						) -- 54
					end -- 54
					local ____try, ____hasReturned = pcall(function() -- 54
						local result -- 43
						GodotNode:checkCodeAsync( -- 44
							project, -- 44
							file, -- 44
							content, -- 44
							function(available, text) -- 44
								if not available then -- 44
									result = failure(text) -- 45
									return -- 45
								end -- 45
								local decoded = safeJsonDecode(text) -- 46
								result = type(decoded) == "table" and type(decoded.success) == "boolean" and decoded or failure("Invalid diagnostics from embedded Godot compiler.") -- 47
							end -- 44
						) -- 44
						while result == nil do -- 44
							sleep(0.02) -- 51
						end -- 51
						resolve( -- 52
							nil, -- 52
							cancelled() and ({success = true, skipped = true}) or result -- 52
						) -- 52
					end) -- 52
					if not ____try then -- 52
						____catch(____hasReturned) -- 52
					end -- 52
					do -- 52
						active:delete(project) -- 56
					end -- 56
				end -- 56
			end)) -- 38
		end -- 37
	) -- 37
end -- 19
return ____exports -- 19