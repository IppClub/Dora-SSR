-- [ts]: GodotBuild.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Log = ____Dora.Log -- 2
local ____GodotCheck = require("Agent.Tool.GodotCheck") -- 3
local checkGodotFile = ____GodotCheck.checkGodotFile -- 3
____exports.GODOT_RUNTIME_VERSION = "4.7.2" -- 6
local activeProjects = __TS__New(Set) -- 7
function ____exports.findGodotProject(workDir, target) -- 10
	workDir = Path:getPath(Path(workDir, "project.godot")) -- 11
	target = Path(target) -- 12
	local dir = Content:isdir(target) and Path:getPath(Path(target, "project.godot")) or Path:getPath(target) -- 13
	while dir == workDir or __TS__StringStartsWith(dir, workDir .. "/") do -- 13
		if Content:exist(Path(dir, "project.godot")) then -- 13
			return dir -- 15
		end -- 15
		if dir == workDir then -- 15
			break -- 16
		end -- 16
		local parent = Path:getPath(dir) -- 17
		if parent == dir then -- 17
			break -- 18
		end -- 18
		dir = parent -- 19
	end -- 19
	return nil -- 21
end -- 10
function ____exports.buildGodotProject(project, cancelled) -- 28
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 28
		project = Path:getPath(Path(project, "project.godot")) -- 29
		local file = Path(project, "project.godot") -- 30
		local completed = {} -- 31
		local function finish(result) -- 32
			local ____result_2 = result -- 32
			local ____result_success_1 -- 32
			if result.success then -- 32
				____result_success_1 = completed -- 32
			else -- 32
				local ____array_0 = __TS__SparseArrayNew(table.unpack(completed)) -- 32
				__TS__SparseArrayPush(____array_0, result) -- 32
				____result_success_1 = {__TS__SparseArraySpread(____array_0)} -- 32
			end -- 32
			return __TS__ObjectAssign({}, ____result_2, {messages = ____result_success_1}) -- 32
		end -- 32
		if activeProjects:has(project) then -- 32
			return ____awaiter_resolve( -- 32
				nil, -- 32
				finish({success = false, file = file, failureKind = "tool", message = "A Godot build is already running for this project."}) -- 33
			) -- 33
		end -- 33
		activeProjects:add(project) -- 34
		local ____hasReturned, ____returnValue -- 34
		local ____try = __TS__AsyncAwaiter(function() -- 34
			local format = string.match( -- 36
				Content:load(file) or "", -- 36
				"config_version%s*=%s*(%d+)" -- 36
			) -- 36
			if format ~= "5" then -- 36
				____hasReturned = true -- 37
				____returnValue = finish({success = false, file = file, message = "Expected a Godot 4 project (config_version=5)."}) -- 37
				return -- 37
			end -- 37
			local main = Content:load(file) or "" -- 38
			if __TS__ArraySome( -- 38
				__TS__StringSplit(main, "\n"), -- 39
				function(____, line) return __TS__StringStartsWith( -- 39
					__TS__StringTrim(line), -- 39
					"config/features" -- 39
				) and __TS__StringIncludes(line, "\"C#\"") end -- 39
			) or #Content:glob(project, {"**/*.gdextension", "!**/.*/**", "!**/node_modules/**"}) > 0 then -- 39
				____hasReturned = true -- 41
				____returnValue = finish({success = false, file = file, message = "Dora Godot projects do not support C#/Mono or native GDExtension sidecars."}) -- 41
				return -- 41
			end -- 41
			for ____, relative in ipairs({ -- 42
				"project.godot", -- 42
				table.unpack(Content:glob(project, { -- 42
					"**/*.gd", -- 42
					"**/*.tscn", -- 42
					"**/*.tres", -- 42
					"**/*.gdshader", -- 42
					"**/*.gdshaderinc", -- 42
					"!**/.*/**", -- 42
					"!**/node_modules/**", -- 42
					"!**/build/**", -- 42
					"!**/dist/**" -- 42
				})) -- 42
			}) do -- 42
				if (cancelled and cancelled()) == true then -- 42
					____hasReturned = true -- 43
					____returnValue = finish({ -- 43
						success = false, -- 43
						file = file, -- 43
						interrupted = true, -- 43
						failureKind = "tool", -- 43
						message = "Godot build canceled." -- 43
					}) -- 43
					return -- 43
				end -- 43
				local target = Path(project, relative) -- 44
				local content = Content:load(target) -- 45
				if content == nil then -- 45
					____hasReturned = true -- 46
					____returnValue = finish({success = false, file = target, message = "Cannot read Godot source file."}) -- 46
					return -- 46
				end -- 46
				local checked = __TS__Await(checkGodotFile(project, target, content, false)) -- 47
				if checked.skipped then -- 47
					____hasReturned = true -- 48
					____returnValue = finish({success = false, file = target, failureKind = "tool", message = "Godot check was superseded by a newer editor request; retry the build."}) -- 48
					return -- 48
				end -- 48
				if not checked.success then -- 48
					local ____opt_5 = checked.info -- 48
					____hasReturned = true -- 49
					____returnValue = finish({ -- 49
						success = false, -- 49
						file = target, -- 49
						failureKind = ____opt_5 and __TS__ArraySome( -- 50
							checked.info, -- 50
							function(____, item) return item[1] == "tool" end -- 50
						) and "tool" or nil, -- 50
						message = checked.info ~= nil and #checked.info > 0 and table.concat( -- 51
							__TS__ArrayMap( -- 52
								checked.info, -- 52
								function(____, item) return (((((("res://" .. Path:getRelative(item[2], project)) .. ":") .. tostring(item[3])) .. ":") .. tostring(item[4])) .. ": ") .. item[5] end -- 52
							), -- 52
							"\n" -- 52
						) or "Embedded Godot compiler check failed." -- 52
					}) -- 52
					return -- 49
				end -- 49
				completed[#completed + 1] = {success = true, file = target, message = "Godot validation passed (bundled runtime)."} -- 54
				Log( -- 56
					"Info", -- 56
					"Built Godot " .. Path( -- 56
						Path:getFilename(project), -- 56
						relative -- 56
					) -- 56
				) -- 56
			end -- 56
			____hasReturned = true -- 58
			____returnValue = finish({ -- 58
				success = true, -- 58
				file = file, -- 58
				message = tostring(#completed) .. " Godot file(s) passed validation." -- 58
			}) -- 58
			return -- 58
		end) -- 58
		____try = ____try.finally( -- 58
			____try, -- 58
			function() -- 58
				return __TS__AsyncAwaiter(function() -- 58
					activeProjects:delete(project) -- 60
				end) -- 60
			end -- 60
		) -- 60
		__TS__Await(____try) -- 35
		if ____hasReturned then -- 35
			return ____awaiter_resolve(nil, ____returnValue) -- 35
		end -- 35
	end) -- 35
end -- 28
return ____exports -- 28