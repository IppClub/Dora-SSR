-- [ts]: GodotBuild.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Path = ____Dora.Path -- 2
local Process = ____Dora.Process -- 2
local once = ____Dora.once -- 2
local sleep = ____Dora.sleep -- 2
local ____Workspace = require("Agent.Tool.Workspace") -- 3
local ensureDirPath = ____Workspace.ensureDirPath -- 3
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 4
local sendWebIDERefreshTree = ____WebIDESync.sendWebIDERefreshTree -- 4
____exports.GODOT_EDITOR_VERSION = "4.7.2" -- 8
local TIMEOUT_SECONDS = 120 -- 9
local OUTPUT_LIMIT = 32768 -- 10
local activeProjects = __TS__New(Set) -- 11
function ____exports.findGodotProject(workDir, target) -- 15
	workDir = Path(workDir) -- 16
	target = Path(target) -- 17
	local dir = Content:isdir(target) and target or Path:getPath(target) -- 18
	while dir == workDir or __TS__StringStartsWith(dir, workDir .. "/") do -- 18
		if Content:exist(Path(dir, "project.godot")) then -- 18
			return dir -- 20
		end -- 20
		if dir == workDir then -- 20
			break -- 21
		end -- 21
		local parent = Path:getPath(dir) -- 22
		if parent == dir then -- 22
			break -- 23
		end -- 23
		dir = parent -- 24
	end -- 24
	return nil -- 26
end -- 15
local function runEditor(program, args, project, cancelled) -- 38
	local handle = Process:spawn({program = program, args = args, cwd = project, env = {NO_COLOR = "1"}}) -- 39
	if handle == nil then -- 39
		return {success = false, output = "Cannot start Godot editor: " .. program, toolFailure = true} -- 40
	end -- 40
	local stdoutOffset = 0 -- 41
	local stderrOffset = 0 -- 41
	local output = "" -- 41
	local diagnosticError = false -- 41
	local deadline = App.runningTime + TIMEOUT_SECONDS -- 42
	do -- 42
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 42
			Process:write(handle) -- 44
			while true do -- 44
				local result = Process:read(handle, stdoutOffset, stderrOffset) -- 46
				stdoutOffset = result.stdoutOffset -- 47
				stderrOffset = result.stderrOffset -- 48
				output = output .. result.stdout .. result.stderr -- 49
				if __TS__StringIncludes(output, "ERROR:") or __TS__StringIncludes(output, "SCRIPT ERROR:") then -- 49
					diagnosticError = true -- 50
				end -- 50
				if #output > OUTPUT_LIMIT then -- 50
					return true, { -- 52
						success = false, -- 52
						output = __TS__StringSlice(output, 0, OUTPUT_LIMIT) .. "\nGodot output exceeded the build diagnostic limit.", -- 52
						toolFailure = true -- 52
					} -- 52
				end -- 52
				if (cancelled and cancelled()) == true then -- 52
					return true, {success = false, output = "Godot build canceled.", interrupted = true, toolFailure = true} -- 54
				end -- 54
				if not result.running then -- 54
					return true, { -- 55
						success = result.exit.exitCode == 0 and not diagnosticError, -- 56
						output = __TS__StringTrim(output) or ("Godot editor exited with code " .. tostring(result.exit.exitCode or "unknown")) .. "." -- 57
					} -- 57
				end -- 57
				if App.runningTime >= deadline then -- 57
					return true, {success = false, output = output .. "\nGodot editor timed out.", toolFailure = true} -- 59
				end -- 59
				sleep(0.02) -- 60
			end -- 60
		end) -- 60
		do -- 60
			Process:stop(handle, "kill-tree") -- 64
			Process:destroy(handle) -- 65
		end -- 65
		if not ____try then -- 65
			error(____hasReturned, 0) -- 65
		end -- 65
		if ____try and ____hasReturned then -- 65
			return ____returnValue -- 43
		end -- 43
	end -- 43
end -- 38
local function editorCandidates() -- 69
	local configured = os.getenv("DORA_GODOT_EDITOR") -- 70
	if configured ~= nil and __TS__StringTrim(configured) ~= "" then -- 70
		return {__TS__StringEndsWith(configured, ".app") and Path(configured, "Contents/MacOS/Godot") or configured} -- 72
	end -- 72
	return App.platform == "macOS" and ({"/Applications/Godot.app/Contents/MacOS/Godot", "godot", "godot4"}) or ({"godot", "godot4"}) -- 74
end -- 69
local VALIDATE_SCRIPT = "extends SceneTree\n\nvar failed := false\n\nfunc _initialize() -> void:\n    inspect_directory(\"res://\")\n    var main_scene := str(ProjectSettings.get_setting(\"application/run/main_scene\", \"\"))\n    if main_scene.is_empty() or not ResourceLoader.exists(main_scene):\n        push_error(\"Godot project main scene is missing: \" + main_scene)\n        failed = true\n    elif not ResourceLoader.load(main_scene) is PackedScene:\n        push_error(\"Godot project main scene must be a PackedScene: \" + main_scene)\n        failed = true\n    quit(1 if failed else 0)\n\nfunc inspect_directory(path: String) -> void:\n    var directory := DirAccess.open(path)\n    if directory == null:\n        push_error(\"Cannot inspect Godot directory: \" + path)\n        failed = true\n        return\n    for file in directory.get_files():\n        var extension := file.get_extension().to_lower()\n        if extension in [\"gd\", \"tscn\", \"tres\", \"gdshader\"]:\n            var resource_path := path.path_join(file)\n            if ResourceLoader.load(resource_path) == null:\n                push_error(\"Cannot load Godot resource: \" + resource_path)\n                failed = true\n    for child in directory.get_directories():\n        if not child.begins_with(\".\") and not child in [\"node_modules\", \"build\", \"dist\"]:\n            inspect_directory(path.path_join(child))\n" -- 79
local function validateGodotProject(project, cancelled) -- 112
	local file = Path(project, "project.godot") -- 113
	local settings = Content:load(file) or "" -- 114
	local format = string.match(settings, "config_version%s*=%s*(%d+)") -- 115
	if format ~= "5" then -- 115
		return {success = false, file = file, message = "Expected a Godot 4 project (config_version=5); automatic project conversion is not part of build."} -- 117
	end -- 117
	if __TS__ArraySome( -- 117
		__TS__StringSplit(settings, "\n"), -- 119
		function(____, line) return __TS__StringStartsWith( -- 119
			__TS__StringTrim(line), -- 119
			"config/features" -- 119
		) and __TS__StringIncludes(line, "\"C#\"") end -- 119
	) or #Content:glob(project, {"**/*.gdextension", "!**/.*/**", "!**/node_modules/**"}) > 0 then -- 119
		return {success = false, file = file, message = "Dora Godot projects do not support Godot C#/Mono or native GDExtension sidecars."} -- 121
	end -- 121
	local editor -- 123
	local lastFailure = "" -- 124
	for ____, candidate in ipairs(editorCandidates()) do -- 125
		local version = runEditor(candidate, {"--version"}, project, cancelled)
		if version.interrupted then -- 126
			return { -- 127
				success = false, -- 127
				file = file, -- 127
				message = version.output, -- 127
				interrupted = true, -- 127
				failureKind = "tool" -- 127
			} -- 127
		end -- 127
		if version.success and __TS__StringStartsWith(version.output, ____exports.GODOT_EDITOR_VERSION .. ".stable") then -- 127
			editor = candidate -- 128
			break -- 128
		end -- 128
		lastFailure = (candidate .. ": ") .. version.output -- 129
	end -- 129
	if editor == nil then -- 129
		return {success = false, file = file, failureKind = "tool", message = (("Set DORA_GODOT_EDITOR to a Godot " .. ____exports.GODOT_EDITOR_VERSION) .. " stable editor executable. ") .. lastFailure} -- 132
	end -- 132
	local dir = Path(project, ".agent/godot") -- 134
	local script = Path(dir, "validate.gd") -- 135
	if not ensureDirPath(dir) or not Content:save(script, VALIDATE_SCRIPT) then -- 135
		return {success = false, file = file, failureKind = "tool", message = "Cannot prepare Godot resource validation script."} -- 137
	end -- 137
	local imported = runEditor(editor, { -- 139
		"--headless",
		"--quiet",
		"--path",
		project, -- 139
		"--editor",
		"--import"
	}, project, cancelled) -- 139
	Content:save( -- 140
		Path(dir, "import.log"), -- 140
		imported.output -- 140
	) -- 140
	sendWebIDERefreshTree() -- 141
	if not imported.success then -- 141
		return { -- 143
			success = false, -- 143
			file = file, -- 143
			message = imported.output, -- 143
			interrupted = imported.interrupted, -- 143
			failureKind = imported.toolFailure and "tool" or nil -- 143
		} -- 143
	end -- 143
	local checked = runEditor(editor, { -- 145
		"--headless",
		"--quiet",
		"--path",
		project, -- 145
		"--script",
		script -- 145
	}, project, cancelled) -- 145
	Content:save( -- 146
		Path(dir, "validate.log"), -- 146
		checked.output -- 146
	) -- 146
	return checked.success and ({success = true, file = file}) or ({ -- 147
		success = false, -- 147
		file = file, -- 147
		message = checked.output, -- 147
		interrupted = checked.interrupted, -- 147
		failureKind = checked.toolFailure and "tool" or nil -- 147
	}) -- 147
end -- 112
function ____exports.buildGodotProject(project, cancelled) -- 150
	project = Path(project) -- 151
	local file = Path(project, "project.godot") -- 152
	if type(_studio_agent_tool_begin) == "function" then -- 152
		return __TS__Promise.resolve({success = false, file = file, failureKind = "tool", message = "Godot game development is not supported in Dora Studio. Use the desktop Dora Web IDE."}) -- 154
	end -- 154
	if App.platform ~= "macOS" and App.platform ~= "Windows" and App.platform ~= "Linux" then -- 154
		return __TS__Promise.resolve({success = false, file = file, failureKind = "tool", message = "Godot import and validation require a desktop Dora host with a matching Godot editor; this runtime has no editor build service."}) -- 157
	end -- 157
	if activeProjects:has(project) then -- 157
		return __TS__Promise.resolve({success = false, file = file, failureKind = "tool", message = "A Godot build is already running for this project. Wait for it to complete before retrying."}) -- 159
	end -- 159
	return __TS__New( -- 160
		__TS__Promise, -- 160
		function(____, resolve) -- 160
			activeProjects:add(project) -- 161
			do -- 161
				local function ____catch(____error) -- 161
					activeProjects:delete(project) -- 175
					resolve( -- 176
						nil, -- 176
						{ -- 176
							success = false, -- 176
							file = file, -- 176
							failureKind = "tool", -- 176
							message = "Cannot schedule Godot build: " .. tostring(____error) -- 176
						} -- 176
					) -- 176
				end -- 176
				local ____try, ____hasReturned = pcall(function() -- 176
					Director.systemScheduler:schedule(once(function() -- 163
						local result -- 164
						do -- 164
							local function ____catch(____error) -- 164
								result = { -- 168
									success = false, -- 168
									file = file, -- 168
									failureKind = "tool", -- 168
									message = "Godot build failed: " .. tostring(____error) -- 168
								} -- 168
							end -- 168
							local ____try, ____hasReturned = pcall(function() -- 168
								result = validateGodotProject(project, cancelled) -- 166
							end) -- 166
							if not ____try then -- 166
								____catch(____hasReturned) -- 166
							end -- 166
							do -- 166
								activeProjects:delete(project) -- 170
							end -- 170
						end -- 170
						resolve(nil, result) -- 172
					end)) -- 163
				end) -- 163
				if not ____try then -- 163
					____catch(____hasReturned) -- 163
				end -- 163
			end -- 163
		end -- 160
	) -- 160
end -- 150
return ____exports -- 150