-- [ts]: GodotCheck.ts
local ____lualib = require("lualib_bundle") -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
	project = Path(project) -- 22
	file = Path(file) -- 23
	if not __TS__StringStartsWith(file, project .. "/") then -- 23
		return __TS__Promise.resolve(failure("Godot check target is outside the project.")) -- 24
	end -- 24
	local settings = Content:load(Path(project, "project.godot")) or "" -- 25
	local format = string.match(settings, "config_version%s*=%s*(%d+)") -- 26
	if format ~= "5" then -- 26
		return __TS__Promise.resolve(failure("Embedded checks require a Godot 4 project (config_version=5).")) -- 27
	end -- 27
	if __TS__ArraySome( -- 27
		__TS__StringSplit(settings, "\n"), -- 28
		function(____, line) return __TS__StringStartsWith( -- 28
			__TS__StringTrim(line), -- 28
			"config/features" -- 28
		) and __TS__StringIncludes(line, "\"C#\"") end -- 28
	) or #Content:glob(project, {"**/*.gdextension", "!**/.*/**", "!**/node_modules/**"}) > 0 then -- 28
		return __TS__Promise.resolve(failure("Embedded checks do not load Godot C#/Mono or native GDExtension sidecars.")) -- 30
	end -- 30
	if GodotNode == nil or type(GodotNode.checkCodeAsync) ~= "function" then -- 30
		return __TS__Promise.resolve(failure("This Dora host has no embedded Godot compiler API; rebuild Dora.")) -- 31
	end -- 31
	sequence = sequence + 1 -- 32
	local id = sequence -- 32
	if coalesce then -- 32
		pending:set(project, id) -- 33
	end -- 33
	local function cancelled() -- 34
		return coalesce and pending:get(project) ~= id -- 34
	end -- 34
	return __TS__New( -- 35
		__TS__Promise, -- 35
		function(____, resolve) -- 35
			Director.systemScheduler:schedule(once(function() -- 36
				while active:has(project) and not cancelled() do -- 36
					sleep(0.02) -- 37
				end -- 37
				if cancelled() then -- 37
					resolve(nil, {success = true, skipped = true}) -- 38
					return -- 38
				end -- 38
				active:add(project) -- 39
				do -- 39
					local function ____catch(____error) -- 39
						resolve( -- 52
							nil, -- 52
							cancelled() and ({success = true, skipped = true}) or failure(tostring(____error)) -- 52
						) -- 52
					end -- 52
					local ____try, ____hasReturned = pcall(function() -- 52
						local result -- 41
						GodotNode:checkCodeAsync( -- 42
							project, -- 42
							file, -- 42
							content, -- 42
							function(available, text) -- 42
								if not available then -- 42
									result = failure(text) -- 43
									return -- 43
								end -- 43
								local decoded = safeJsonDecode(text) -- 44
								result = type(decoded) == "table" and type(decoded.success) == "boolean" and decoded or failure("Invalid diagnostics from embedded Godot compiler.") -- 45
							end -- 42
						) -- 42
						while result == nil do -- 42
							sleep(0.02) -- 49
						end -- 49
						resolve( -- 50
							nil, -- 50
							cancelled() and ({success = true, skipped = true}) or result -- 50
						) -- 50
					end) -- 50
					if not ____try then -- 50
						____catch(____hasReturned) -- 50
					end -- 50
					do -- 50
						active:delete(project) -- 54
					end -- 54
				end -- 54
			end)) -- 36
		end -- 35
	) -- 35
end -- 19
return ____exports -- 19