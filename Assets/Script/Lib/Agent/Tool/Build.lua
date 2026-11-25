-- [ts]: Build.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray -- 1
local ____exports = {} -- 1
local runStudioBuild, TRANSPILE_BUILD_TIMEOUT_SECONDS, MISSING_LUA_OUTPUT_MESSAGE -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local wait = ____Dora.wait -- 2
local App = ____Dora.App -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 4
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 4
local ____GodotBuild = require("Agent.Tool.GodotBuild") -- 5
local buildGodotProject = ____GodotBuild.buildGodotProject -- 5
local findGodotProject = ____GodotBuild.findGodotProject -- 5
local ____BuildPlan = require("Agent.Tool.BuildPlan") -- 6
local planDirectoryBuild = ____BuildPlan.planDirectoryBuild -- 6
local ____Workspace = require("Agent.Tool.Workspace") -- 7
local resolveWorkspaceSearchPath = ____Workspace.resolveWorkspaceSearchPath -- 8
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 9
function runStudioBuild(file, content, projectRoot, operation, saveLua, isCancelled) -- 95
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 95
		local result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool is unavailable"} -- 96
		if type(_studio_agent_tool_begin) ~= "function" or type(_studio_agent_tool_poll) ~= "function" then -- 96
			return ____awaiter_resolve(nil, result) -- 96
		end -- 96
		local requestId -- 98
		local ____hasReturned, ____returnValue -- 98
		local ____try = __TS__AsyncAwaiter(function() -- 98
			requestId = _studio_agent_tool_begin(operation, file, content, projectRoot) -- 99
		end) -- 99
		____try = ____try.catch( -- 99
			____try, -- 99
			function(____, ____error) -- 99
				return __TS__AsyncAwaiter(function() -- 99
					____hasReturned = true -- 100
					____returnValue = { -- 100
						success = false, -- 100
						file = file, -- 100
						failureKind = "tool", -- 100
						message = tostring(____error) -- 100
					} -- 100
					return -- 100
				end) -- 100
			end -- 100
		) -- 100
		__TS__Await(____try) -- 99
		if ____hasReturned then -- 99
			return ____awaiter_resolve(nil, ____returnValue) -- 99
		end -- 99
		__TS__Await(__TS__New( -- 101
			__TS__Promise, -- 101
			function(____, resolve) -- 101
				Director.systemScheduler:schedule(once(function() -- 102
					local deadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 103
					local answer -- 104
					wait(function() -- 105
						if (isCancelled and isCancelled()) == true or App.runningTime >= deadline then -- 105
							return true -- 106
						end -- 106
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 107
						return answer ~= nil -- 108
					end) -- 105
					if (isCancelled and isCancelled()) == true then -- 105
						result = { -- 110
							success = false, -- 110
							file = file, -- 110
							failureKind = "tool", -- 110
							message = "build canceled", -- 110
							interrupted = true -- 110
						} -- 110
					elseif not answer then -- 110
						result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool timed out"} -- 111
					elseif answer.success and type(answer.luaCode) == "string" and __TS__StringTrim(answer.luaCode) ~= "" then -- 111
						if saveLua then -- 111
							local luaFile = Path:replaceExt(file, "lua") -- 114
							result = Content:save(luaFile, answer.luaCode) and ({success = true, file = file}) or ({success = false, file = file, message = "failed to save " .. luaFile}) -- 115
						else -- 115
							result = {success = true, file = file} -- 116
						end -- 116
					else -- 116
						result = {success = false, file = file, message = answer.message or (answer.success and MISSING_LUA_OUTPUT_MESSAGE or "Studio Agent build tool failed")} -- 117
					end -- 117
					resolve(nil) -- 118
				end)) -- 102
			end -- 101
		)) -- 101
		if not result.success and (result.interrupted == true or result.message == "Studio Agent build tool timed out") then -- 101
			if _studio_agent_tool_cancel ~= nil then -- 101
				_studio_agent_tool_cancel(requestId) -- 121
			end -- 121
		end -- 121
		return ____awaiter_resolve(nil, result) -- 121
	end) -- 121
end -- 121
local function isDtsFile(path) -- 42
	return Path:getExt(Path:getName(path)) == "d" -- 43
end -- 42
local function isTiledEditorContent(content) -- 46
	return __TS__StringStartsWith( -- 47
		__TS__StringTrim(content), -- 47
		"<?xml" -- 47
	) -- 47
end -- 46
local function getSupportedBuildKind(path) -- 52
	repeat -- 52
		local ____switch5 = Path:getExt(path) -- 52
		local ____cond5 = ____switch5 == "ts" or ____switch5 == "tsx" -- 52
		if ____cond5 then -- 52
			return "ts" -- 54
		end -- 54
		____cond5 = ____cond5 or ____switch5 == "xml" -- 54
		if ____cond5 then -- 54
			return "xml" -- 55
		end -- 55
		____cond5 = ____cond5 or ____switch5 == "tl" -- 55
		if ____cond5 then -- 55
			return "teal" -- 56
		end -- 56
		____cond5 = ____cond5 or ____switch5 == "lua" -- 56
		if ____cond5 then -- 56
			return "lua" -- 57
		end -- 57
		____cond5 = ____cond5 or ____switch5 == "yue" -- 57
		if ____cond5 then -- 57
			return "yue" -- 58
		end -- 58
		____cond5 = ____cond5 or ____switch5 == "yarn" -- 58
		if ____cond5 then -- 58
			return "yarn" -- 59
		end -- 59
		do -- 59
			return nil -- 60
		end -- 60
	until true -- 60
end -- 52
local function runSingleNonTsBuild(file, projectRoot, isCancelled) -- 64
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 64
		if type(_studio_agent_tool_begin) == "function" then -- 64
			if not projectRoot then -- 64
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 64
			end -- 64
			local kind = getSupportedBuildKind(file) -- 67
			if kind ~= "teal" and kind ~= "lua" and kind ~= "yarn" and kind ~= "yue" and kind ~= "xml" then -- 67
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = ("Studio Agent " .. (kind or "unknown")) .. " build tool is not connected"}) -- 67
			end -- 67
			local content = Content:load(file) -- 69
			if content == nil then -- 69
				return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to read file"}) -- 69
			end -- 69
			return ____awaiter_resolve( -- 69
				nil, -- 69
				runStudioBuild( -- 74
					file, -- 74
					content, -- 74
					projectRoot, -- 74
					"build-script", -- 74
					kind == "teal", -- 74
					isCancelled -- 74
				) -- 74
			) -- 74
		end -- 74
		return ____awaiter_resolve( -- 74
			nil, -- 74
			__TS__New( -- 76
				__TS__Promise, -- 76
				function(____, resolve) -- 76
					local moduleName = "Script.Dev.WebServer" -- 77
					local ____require_result_0 = require(moduleName) -- 78
					local buildAsync = ____require_result_0.buildAsync -- 78
					Director.systemScheduler:schedule(once(function() -- 79
						local result = buildAsync(file, projectRoot) -- 80
						resolve(nil, result) -- 81
					end)) -- 79
				end -- 76
			) -- 76
		) -- 76
	end) -- 76
end -- 64
TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 86
MISSING_LUA_OUTPUT_MESSAGE = "Compiler returned no Lua output" -- 87
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 125
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 125
		if type(_studio_agent_tool_begin) == "function" then -- 125
			if not projectRoot then -- 125
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 125
			end -- 125
			return ____awaiter_resolve( -- 125
				nil, -- 125
				runStudioBuild( -- 133
					file, -- 133
					content, -- 133
					projectRoot, -- 133
					"transpile-ts", -- 133
					true, -- 133
					isCancelled -- 133
				) -- 133
			) -- 133
		end -- 133
		return ____awaiter_resolve( -- 133
			nil, -- 133
			__TS__New( -- 135
				__TS__Promise, -- 135
				function(____, resolve) -- 135
					local moduleName = "Script.Dev.WebServer" -- 136
					local webServer = require(moduleName) -- 137
					Director.systemScheduler:schedule(once(function() -- 143
						resolve( -- 144
							nil, -- 144
							webServer.transpileTSFile( -- 144
								file, -- 144
								content, -- 144
								projectRoot, -- 144
								nil, -- 144
								isCancelled -- 144
							) -- 144
						) -- 144
					end)) -- 143
				end -- 135
			) -- 135
		) -- 135
	end) -- 135
end -- 125
local function finalizeBuildResult(workDir, messages) -- 149
	local normalized = __TS__ArrayMap( -- 150
		messages, -- 150
		function(____, m) return __TS__ObjectAssign( -- 150
			{}, -- 150
			m, -- 150
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 150
		) end -- 150
	) -- 150
	local total = #normalized -- 151
	if total == 0 then -- 151
		return { -- 152
			success = false, -- 152
			message = "No code files were compiled; declarations and skipped files do not count as a build.", -- 152
			total = 0, -- 152
			passed = 0, -- 152
			failed = 0 -- 152
		} -- 152
	end -- 152
	local failed = 0 -- 153
	do -- 153
		local i = 0 -- 154
		while i < #normalized do -- 154
			if not normalized[i + 1].success then -- 154
				failed = failed + 1 -- 155
			end -- 155
			i = i + 1 -- 154
		end -- 154
	end -- 154
	local passed = total - failed -- 157
	if failed > 0 then -- 157
		local interrupted = __TS__ArraySome( -- 159
			normalized, -- 159
			function(____, message) return not message.success and message.interrupted == true end -- 159
		) -- 159
		local toolFailures = __TS__ArrayFilter( -- 160
			normalized, -- 160
			function(____, m) return not m.success and m.failureKind == "tool" end -- 160
		) -- 160
		return { -- 161
			success = false, -- 162
			message = #toolFailures > 0 and table.concat( -- 163
				__TS__ArrayMap( -- 163
					toolFailures, -- 163
					function(____, m) return m.message end -- 163
				), -- 163
				"; " -- 163
			) or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 163
			total = total, -- 164
			passed = passed, -- 165
			failed = failed, -- 166
			messages = normalized, -- 167
			interrupted = interrupted or nil, -- 168
			failureKind = #toolFailures > 0 and "tool" or nil -- 169
		} -- 169
	end -- 169
	return { -- 172
		success = true, -- 173
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 174
		total = total, -- 175
		passed = passed, -- 176
		failed = 0, -- 177
		messages = normalized -- 178
	} -- 178
end -- 149
function ____exports.build(req) -- 182
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 182
		local ____this_10 -- 182
		____this_10 = req -- 183
		local ____opt_9 = ____this_10.isCancelled -- 183
		if (____opt_9 and ____opt_9(____this_10)) == true then -- 183
			return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "Build canceled.", interrupted = true}) -- 183
		end -- 183
		local targetRel = req.path or "" -- 186
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 187
		if not target then -- 187
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 187
		end -- 187
		if not Content:exist(target) then -- 187
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 187
		end -- 187
		local messages = {} -- 194
		local godotProject = findGodotProject(req.workDir, target) -- 197
		if godotProject ~= nil then -- 197
			local result = __TS__Await(buildGodotProject(godotProject, req.isCancelled)) -- 199
			__TS__ArrayPushArray(messages, result.messages or ({result})) -- 200
			if not result.success then -- 200
				return ____awaiter_resolve( -- 200
					nil, -- 200
					finalizeBuildResult(req.workDir, messages) -- 201
				) -- 201
			end -- 201
		end -- 201
		if not Content:isdir(target) then -- 201
			local kind = getSupportedBuildKind(target) -- 204
			if not kind then -- 204
				if godotProject ~= nil then -- 204
					return ____awaiter_resolve( -- 204
						nil, -- 204
						finalizeBuildResult(req.workDir, messages) -- 206
					) -- 206
				end -- 206
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 206
			end -- 206
			if kind == "ts" then -- 206
				local content = Content:load(target) -- 210
				if content == nil then -- 210
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 210
				end -- 210
				if isTiledEditorContent(content) then -- 210
					Log("Info", "[build] skip tiled editor file=" .. target) -- 215
					return ____awaiter_resolve( -- 215
						nil, -- 215
						finalizeBuildResult(req.workDir, messages) -- 216
					) -- 216
				end -- 216
				if not sendWebIDEFileUpdate(target, true, content) then -- 216
					return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "failed to encode UpdateFile request"}) -- 216
				end -- 216
				if not isDtsFile(target) then -- 216
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 222
				end -- 222
			else -- 222
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target, req.workDir, req.isCancelled)) -- 225
			end -- 225
			Log( -- 227
				"Info", -- 227
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 227
			) -- 227
			return ____awaiter_resolve( -- 227
				nil, -- 227
				finalizeBuildResult(req.workDir, messages) -- 228
			) -- 228
		end -- 228
		for ____, unit in ipairs(planDirectoryBuild(target, req.workDir)) do -- 230
			do -- 230
				if unit.godot and unit.godot ~= godotProject then -- 230
					local result = __TS__Await(buildGodotProject(unit.godot, req.isCancelled)) -- 232
					__TS__ArrayPushArray(messages, result.messages or ({result})) -- 233
					local ____this_12 -- 233
					____this_12 = req -- 234
					local ____opt_11 = ____this_12.isCancelled -- 234
					if (____opt_11 and ____opt_11(____this_12)) == true then -- 234
						return ____awaiter_resolve( -- 234
							nil, -- 234
							finalizeBuildResult(req.workDir, messages) -- 234
						) -- 234
					end -- 234
					if not result.success then -- 234
						goto __continue58 -- 235
					end -- 235
				end -- 235
				local projectRoot = unit.projectRoot or req.workDir -- 237
				local ____temp_13 -- 238
				if type(_studio_agent_tool_begin) ~= "function" then -- 238
					____temp_13 = require("Script.Dev.WebServer").buildTypeScriptFiles -- 239
				else -- 239
					____temp_13 = nil -- 242
				end -- 242
				local nativeCompiler = ____temp_13 -- 238
				local tsFiles = {} -- 243
				for ____, file in ipairs(unit.files) do -- 244
					do -- 244
						local ____this_15 -- 244
						____this_15 = req -- 245
						local ____opt_14 = ____this_15.isCancelled -- 245
						if (____opt_14 and ____opt_14(____this_15)) == true then -- 245
							return ____awaiter_resolve(nil, { -- 245
								success = false, -- 246
								failureKind = "tool", -- 246
								message = "Build canceled.", -- 246
								messages = messages, -- 246
								interrupted = true -- 246
							}) -- 246
						end -- 246
						local kind = getSupportedBuildKind(file) -- 248
						if not kind then -- 248
							goto __continue62 -- 249
						end -- 249
						if kind ~= "ts" then -- 249
							messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file, projectRoot, req.isCancelled)) -- 251
							goto __continue62 -- 252
						end -- 252
						if isDtsFile(file) then -- 252
							goto __continue62 -- 254
						end -- 254
						if nativeCompiler then -- 254
							tsFiles[#tsFiles + 1] = file -- 256
							goto __continue62 -- 257
						end -- 257
						local content = Content:load(file) -- 259
						if content == nil then -- 259
							messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 261
							goto __continue62 -- 262
						end -- 262
						if isTiledEditorContent(content) then -- 262
							goto __continue62 -- 264
						end -- 264
						if not sendWebIDEFileUpdate(file, true, content) then -- 264
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request", failureKind = "tool"} -- 266
							goto __continue62 -- 267
						end -- 267
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, projectRoot, req.isCancelled)) -- 269
					end -- 269
					::__continue62:: -- 269
				end -- 269
				if nativeCompiler and #tsFiles > 0 then -- 269
					local results = __TS__Await(__TS__New( -- 272
						__TS__Promise, -- 272
						function(____, resolve) -- 272
							Director.systemScheduler:schedule(once(function() return resolve( -- 273
								nil, -- 273
								nativeCompiler(tsFiles, projectRoot, req.isCancelled) -- 273
							) end)) -- 273
						end -- 272
					)) -- 272
					__TS__ArrayPushArray(messages, results) -- 275
				end -- 275
				local ____this_17 -- 275
				____this_17 = req -- 277
				local ____opt_16 = ____this_17.isCancelled -- 277
				if (____opt_16 and ____opt_16(____this_17)) == true then -- 277
					return ____awaiter_resolve(nil, { -- 277
						success = false, -- 278
						failureKind = "tool", -- 278
						message = "Build canceled.", -- 278
						messages = messages, -- 278
						interrupted = true -- 278
					}) -- 278
				end -- 278
			end -- 278
			::__continue58:: -- 278
		end -- 278
		if #messages == 0 then -- 278
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 283
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 283
		end -- 283
		Log( -- 286
			"Info", -- 286
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 286
		) -- 286
		return ____awaiter_resolve( -- 286
			nil, -- 286
			finalizeBuildResult(req.workDir, messages) -- 287
		) -- 287
	end) -- 287
end -- 182
return ____exports -- 182