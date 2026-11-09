-- [ts]: Build.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local runStudioBuild, TRANSPILE_BUILD_TIMEOUT_SECONDS, MISSING_LUA_OUTPUT_MESSAGE -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Node = ____Dora.Node -- 2
local emit = ____Dora.emit -- 2
local wait = ____Dora.wait -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 4
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 4
local ____GodotBuild = require("Agent.Tool.GodotBuild") -- 5
local buildGodotProject = ____GodotBuild.buildGodotProject -- 5
local findGodotProject = ____GodotBuild.findGodotProject -- 5
local ____Workspace = require("Agent.Tool.Workspace") -- 6
local resolveWorkspaceSearchPath = ____Workspace.resolveWorkspaceSearchPath -- 7
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 8
local listFiles = ____Workspace.listFiles -- 9
local codeExtensions = ____Workspace.codeExtensions -- 10
function runStudioBuild(file, content, projectRoot, operation, saveLua, isCancelled) -- 102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 102
		local result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool is unavailable"} -- 103
		if type(_studio_agent_tool_begin) ~= "function" or type(_studio_agent_tool_poll) ~= "function" then -- 103
			return ____awaiter_resolve(nil, result) -- 103
		end -- 103
		local requestId -- 105
		local ____hasReturned, ____returnValue -- 105
		local ____try = __TS__AsyncAwaiter(function() -- 105
			requestId = _studio_agent_tool_begin(operation, file, content, projectRoot) -- 106
		end) -- 106
		____try = ____try.catch( -- 106
			____try, -- 106
			function(____, ____error) -- 106
				return __TS__AsyncAwaiter(function() -- 106
					____hasReturned = true -- 107
					____returnValue = { -- 107
						success = false, -- 107
						file = file, -- 107
						failureKind = "tool", -- 107
						message = tostring(____error) -- 107
					} -- 107
					return -- 107
				end) -- 107
			end -- 107
		) -- 107
		__TS__Await(____try) -- 106
		if ____hasReturned then -- 106
			return ____awaiter_resolve(nil, ____returnValue) -- 106
		end -- 106
		__TS__Await(__TS__New( -- 108
			__TS__Promise, -- 108
			function(____, resolve) -- 108
				Director.systemScheduler:schedule(once(function() -- 109
					local deadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 110
					local answer -- 111
					wait(function() -- 112
						if (isCancelled and isCancelled()) == true or App.runningTime >= deadline then -- 112
							return true -- 113
						end -- 113
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 114
						return answer ~= nil -- 115
					end) -- 112
					if (isCancelled and isCancelled()) == true then -- 112
						result = { -- 117
							success = false, -- 117
							file = file, -- 117
							failureKind = "tool", -- 117
							message = "build canceled", -- 117
							interrupted = true -- 117
						} -- 117
					elseif not answer then -- 117
						result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool timed out"} -- 118
					elseif answer.success and type(answer.luaCode) == "string" and __TS__StringTrim(answer.luaCode) ~= "" then -- 118
						if saveLua then -- 118
							local luaFile = Path:replaceExt(file, "lua") -- 121
							result = Content:save(luaFile, answer.luaCode) and ({success = true, file = file}) or ({success = false, file = file, message = "failed to save " .. luaFile}) -- 122
						else -- 122
							result = {success = true, file = file} -- 123
						end -- 123
					else -- 123
						result = {success = false, file = file, message = answer.message or (answer.success and MISSING_LUA_OUTPUT_MESSAGE or "Studio Agent build tool failed")} -- 124
					end -- 124
					resolve(nil) -- 125
				end)) -- 109
			end -- 108
		)) -- 108
		if not result.success and (result.interrupted == true or result.message == "Studio Agent build tool timed out") then -- 108
			if _studio_agent_tool_cancel ~= nil then -- 108
				_studio_agent_tool_cancel(requestId) -- 128
			end -- 128
		end -- 128
		return ____awaiter_resolve(nil, result) -- 128
	end) -- 128
end -- 128
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
local function encodeJSON(obj) -- 64
	local text = safeJsonEncode(obj) -- 65
	return text -- 66
end -- 64
local function runSingleNonTsBuild(file, projectRoot, isCancelled) -- 69
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 69
		if type(_studio_agent_tool_begin) == "function" then -- 69
			if not projectRoot then -- 69
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 69
			end -- 69
			local kind = getSupportedBuildKind(file) -- 72
			if kind ~= "teal" and kind ~= "lua" and kind ~= "yarn" and kind ~= "yue" and kind ~= "xml" then -- 72
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = ("Studio Agent " .. (kind or "unknown")) .. " build tool is not connected"}) -- 72
			end -- 72
			local content = Content:load(file) -- 74
			if content == nil then -- 74
				return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to read file"}) -- 74
			end -- 74
			return ____awaiter_resolve( -- 74
				nil, -- 74
				runStudioBuild( -- 79
					file, -- 79
					content, -- 79
					projectRoot, -- 79
					"build-script", -- 79
					kind == "teal", -- 79
					isCancelled -- 79
				) -- 79
			) -- 79
		end -- 79
		return ____awaiter_resolve( -- 79
			nil, -- 79
			__TS__New( -- 81
				__TS__Promise, -- 81
				function(____, resolve) -- 81
					local moduleName = "Script.Dev.WebServer" -- 82
					local ____require_result_0 = require(moduleName) -- 83
					local buildAsync = ____require_result_0.buildAsync -- 83
					Director.systemScheduler:schedule(once(function() -- 84
						local result = buildAsync(file) -- 85
						resolve(nil, result) -- 86
					end)) -- 84
				end -- 81
			) -- 81
		) -- 81
	end) -- 81
end -- 69
local transpileRequestSeq = 0 -- 91
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 92
TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 93
MISSING_LUA_OUTPUT_MESSAGE = "Compiler returned no Lua output" -- 94
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 132
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 132
		if type(_studio_agent_tool_begin) == "function" then -- 132
			if not projectRoot then -- 132
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 132
			end -- 132
			return ____awaiter_resolve( -- 132
				nil, -- 132
				runStudioBuild( -- 140
					file, -- 140
					content, -- 140
					projectRoot, -- 140
					"transpile-ts", -- 140
					true, -- 140
					isCancelled -- 140
				) -- 140
			) -- 140
		end -- 140
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 140
			return ____awaiter_resolve( -- 140
				nil, -- 140
				__TS__New( -- 143
					__TS__Promise, -- 143
					function(____, resolve) -- 143
						local moduleName = "Script.Dev.WebServer" -- 144
						local webServer = require(moduleName) -- 145
						Director.systemScheduler:schedule(once(function() -- 155
							resolve( -- 156
								nil, -- 156
								webServer.transpileTSFile( -- 156
									file, -- 156
									content, -- 156
									projectRoot, -- 156
									nil, -- 156
									isCancelled -- 156
								) -- 156
							) -- 156
						end)) -- 155
					end -- 143
				) -- 143
			) -- 143
		end -- 143
		local done = false -- 160
		local ready = false -- 161
		transpileRequestSeq = transpileRequestSeq + 1 -- 162
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 163
		local result = {success = false, file = file, failureKind = "tool", message = "Web IDE not connected"} -- 164
		if HttpServer.wsConnectionCount == 0 then -- 164
			return ____awaiter_resolve(nil, result) -- 164
		end -- 164
		local listener = Node() -- 173
		listener:gslot( -- 174
			"AppWS", -- 174
			function(event) -- 174
				if event.type ~= "Receive" then -- 174
					return -- 175
				end -- 175
				local res = safeJsonDecode(event.msg) -- 176
				if not res or __TS__ArrayIsArray(res) then -- 176
					return -- 177
				end -- 177
				local payload = res -- 178
				if payload.id ~= requestId then -- 178
					return -- 179
				end -- 179
				if payload.name == "TranspileTSProbe" then -- 179
					ready = payload.success == true -- 181
					return -- 182
				end -- 182
				if payload.name ~= "TranspileTS" then -- 182
					return -- 184
				end -- 184
				if payload.success and type(payload.luaCode) == "string" and __TS__StringTrim(payload.luaCode) ~= "" then -- 184
					local luaFile = Path:replaceExt(file, "lua") -- 186
					if Content:save( -- 186
						luaFile, -- 187
						tostring(payload.luaCode) -- 187
					) then -- 187
						result = {success = true, file = file} -- 188
					else -- 188
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 190
					end -- 190
				else -- 190
					result = { -- 193
						success = false, -- 193
						file = file, -- 193
						message = payload.success and MISSING_LUA_OUTPUT_MESSAGE or tostring(payload.message), -- 193
						failureKind = payload.failureKind == "tool" and "tool" or nil -- 193
					} -- 193
				end -- 193
				done = true -- 195
			end -- 174
		) -- 174
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 197
		local buildPayload = encodeJSON({ -- 198
			name = "TranspileTS", -- 199
			id = requestId, -- 200
			file = file, -- 201
			content = content, -- 202
			projectRoot = projectRoot -- 203
		}) -- 203
		if not probePayload or not buildPayload then -- 203
			listener:removeFromParent() -- 206
			return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "failed to encode transpile request"}) -- 206
		end -- 206
		__TS__Await(__TS__New( -- 209
			__TS__Promise, -- 209
			function(____, resolve) -- 209
				Director.systemScheduler:schedule(once(function() -- 210
					emit("AppWS", "Send", probePayload) -- 211
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 212
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 213
					if not ready then -- 213
						listener:removeFromParent() -- 218
						if (isCancelled and isCancelled()) == true then -- 218
							result = { -- 220
								success = false, -- 220
								file = file, -- 220
								failureKind = "tool", -- 220
								message = "build canceled", -- 220
								interrupted = true -- 220
							} -- 220
						elseif HttpServer.wsConnectionCount == 0 then -- 220
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 222
						else -- 222
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpiler is not ready"} -- 224
						end -- 224
						resolve(nil) -- 226
						return -- 227
					end -- 227
					emit("AppWS", "Send", buildPayload) -- 229
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 230
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 231
					if not done then -- 231
						listener:removeFromParent() -- 236
						if (isCancelled and isCancelled()) == true then -- 236
							result = { -- 238
								success = false, -- 238
								file = file, -- 238
								failureKind = "tool", -- 238
								message = "build canceled", -- 238
								interrupted = true -- 238
							} -- 238
						elseif HttpServer.wsConnectionCount == 0 then -- 238
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 240
						else -- 240
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpile timed out"} -- 242
						end -- 242
					end -- 242
					resolve(nil) -- 245
				end)) -- 210
			end -- 209
		)) -- 209
		return ____awaiter_resolve(nil, result) -- 209
	end) -- 209
end -- 132
local function finalizeBuildResult(workDir, messages) -- 251
	local normalized = __TS__ArrayMap( -- 252
		messages, -- 252
		function(____, m) return __TS__ObjectAssign( -- 252
			{}, -- 252
			m, -- 252
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 252
		) end -- 252
	) -- 252
	local total = #normalized -- 253
	if total == 0 then -- 253
		return { -- 254
			success = false, -- 254
			message = "No code files were compiled; declarations and skipped files do not count as a build.", -- 254
			total = 0, -- 254
			passed = 0, -- 254
			failed = 0 -- 254
		} -- 254
	end -- 254
	local failed = 0 -- 255
	do -- 255
		local i = 0 -- 256
		while i < #normalized do -- 256
			if not normalized[i + 1].success then -- 256
				failed = failed + 1 -- 257
			end -- 257
			i = i + 1 -- 256
		end -- 256
	end -- 256
	local passed = total - failed -- 259
	if failed > 0 then -- 259
		local interrupted = __TS__ArraySome( -- 261
			normalized, -- 261
			function(____, message) return not message.success and message.interrupted == true end -- 261
		) -- 261
		local toolFailures = __TS__ArrayFilter( -- 262
			normalized, -- 262
			function(____, m) return not m.success and m.failureKind == "tool" end -- 262
		) -- 262
		return { -- 263
			success = false, -- 264
			message = #toolFailures > 0 and table.concat( -- 265
				__TS__ArrayMap( -- 265
					toolFailures, -- 265
					function(____, m) return m.message end -- 265
				), -- 265
				"; " -- 265
			) or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 265
			total = total, -- 266
			passed = passed, -- 267
			failed = failed, -- 268
			messages = normalized, -- 269
			interrupted = interrupted or nil, -- 270
			failureKind = #toolFailures > 0 and "tool" or nil -- 271
		} -- 271
	end -- 271
	return { -- 274
		success = true, -- 275
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 276
		total = total, -- 277
		passed = passed, -- 278
		failed = 0, -- 279
		messages = normalized -- 280
	} -- 280
end -- 251
function ____exports.build(req) -- 284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 284
		local ____this_18 -- 284
		____this_18 = req -- 285
		local ____opt_17 = ____this_18.isCancelled -- 285
		if (____opt_17 and ____opt_17(____this_18)) == true then -- 285
			return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "Build canceled.", interrupted = true}) -- 285
		end -- 285
		local targetRel = req.path or "" -- 288
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 289
		if not target then -- 289
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 289
		end -- 289
		if not Content:exist(target) then -- 289
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 289
		end -- 289
		local messages = {} -- 296
		local godotProject = findGodotProject(req.workDir, target) -- 299
		if godotProject ~= nil then -- 299
			messages[#messages + 1] = __TS__Await(buildGodotProject(godotProject, req.isCancelled)) -- 301
			if not messages[1].success then -- 301
				return ____awaiter_resolve( -- 301
					nil, -- 301
					finalizeBuildResult(req.workDir, messages) -- 302
				) -- 302
			end -- 302
		end -- 302
		if not Content:isdir(target) then -- 302
			local kind = getSupportedBuildKind(target) -- 305
			if not kind then -- 305
				if godotProject ~= nil then -- 305
					return ____awaiter_resolve( -- 305
						nil, -- 305
						finalizeBuildResult(req.workDir, messages) -- 307
					) -- 307
				end -- 307
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 307
			end -- 307
			if kind == "ts" then -- 307
				local content = Content:load(target) -- 311
				if content == nil then -- 311
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 311
				end -- 311
				if isTiledEditorContent(content) then -- 311
					Log("Info", "[build] skip tiled editor file=" .. target) -- 316
					return ____awaiter_resolve( -- 316
						nil, -- 316
						finalizeBuildResult(req.workDir, messages) -- 317
					) -- 317
				end -- 317
				if not sendWebIDEFileUpdate(target, true, content) then -- 317
					return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "failed to encode UpdateFile request"}) -- 317
				end -- 317
				if not isDtsFile(target) then -- 317
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 323
				end -- 323
			else -- 323
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target, req.workDir, req.isCancelled)) -- 326
			end -- 326
			Log( -- 328
				"Info", -- 328
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 328
			) -- 328
			return ____awaiter_resolve( -- 328
				nil, -- 328
				finalizeBuildResult(req.workDir, messages) -- 329
			) -- 329
		end -- 329
		local listResult = listFiles({ -- 331
			workDir = req.workDir, -- 332
			path = targetRel, -- 333
			globs = __TS__ArrayMap( -- 334
				codeExtensions, -- 334
				function(____, e) return "**/*" .. e end -- 334
			), -- 334
			maxEntries = 10000 -- 335
		}) -- 335
		local relFiles = listResult.success and listResult.files or ({}) -- 338
		local tsFileData = {} -- 339
		local buildQueue = {} -- 340
		for ____, rel in ipairs(relFiles) do -- 341
			do -- 341
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 342
				if Path:getFilename(file) == "project.godot" and Path:getPath(file) ~= godotProject then -- 342
					messages[#messages + 1] = __TS__Await(buildGodotProject( -- 344
						Path:getPath(file), -- 344
						req.isCancelled -- 344
					)) -- 344
					local ____this_20 -- 344
					____this_20 = req -- 345
					local ____opt_19 = ____this_20.isCancelled -- 345
					if (____opt_19 and ____opt_19(____this_20)) == true then -- 345
						return ____awaiter_resolve( -- 345
							nil, -- 345
							finalizeBuildResult(req.workDir, messages) -- 345
						) -- 345
					end -- 345
				end -- 345
				local kind = getSupportedBuildKind(file) -- 347
				if not kind then -- 347
					goto __continue85 -- 348
				end -- 348
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 349
				if kind ~= "ts" then -- 349
					goto __continue85 -- 351
				end -- 351
				local content = Content:load(file) -- 353
				if content == nil then -- 353
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 355
					goto __continue85 -- 356
				end -- 356
				if isTiledEditorContent(content) then -- 356
					Log("Info", "[build] skip tiled editor file=" .. file) -- 359
					goto __continue85 -- 360
				end -- 360
				tsFileData[file] = content -- 362
			end -- 362
			::__continue85:: -- 362
		end -- 362
		do -- 362
			local i = 0 -- 364
			while i < #buildQueue do -- 364
				do -- 364
					local ____this_22 -- 364
					____this_22 = req -- 365
					local ____opt_21 = ____this_22.isCancelled -- 365
					if (____opt_21 and ____opt_21(____this_22)) == true then -- 365
						return ____awaiter_resolve(nil, { -- 365
							success = false, -- 366
							failureKind = "tool", -- 366
							message = "Build canceled.", -- 366
							messages = messages, -- 366
							interrupted = true -- 366
						}) -- 366
					end -- 366
					local ____buildQueue_index_23 = buildQueue[i + 1] -- 368
					local file = ____buildQueue_index_23.file -- 368
					local kind = ____buildQueue_index_23.kind -- 368
					if kind == "ts" then -- 368
						local content = tsFileData[file] -- 370
						if content == nil or isDtsFile(file) then -- 370
							goto __continue94 -- 372
						end -- 372
						if not sendWebIDEFileUpdate(file, true, content) then -- 372
							messages[#messages + 1] = {success = false, file = file, failureKind = "tool", message = "failed to encode UpdateFile request"} -- 375
							goto __continue94 -- 376
						end -- 376
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 378
						goto __continue94 -- 379
					end -- 379
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file, req.workDir, req.isCancelled)) -- 381
				end -- 381
				::__continue94:: -- 381
				i = i + 1 -- 364
			end -- 364
		end -- 364
		if #messages == 0 then -- 364
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 384
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 384
		end -- 384
		Log( -- 387
			"Info", -- 387
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 387
		) -- 387
		return ____awaiter_resolve( -- 387
			nil, -- 387
			finalizeBuildResult(req.workDir, messages) -- 388
		) -- 388
	end) -- 388
end -- 284
return ____exports -- 284