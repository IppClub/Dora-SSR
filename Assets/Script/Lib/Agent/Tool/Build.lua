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
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray -- 1
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
function runStudioBuild(file, content, projectRoot, operation, saveLua, isCancelled) -- 103
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 103
		local result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool is unavailable"} -- 104
		if type(_studio_agent_tool_begin) ~= "function" or type(_studio_agent_tool_poll) ~= "function" then -- 104
			return ____awaiter_resolve(nil, result) -- 104
		end -- 104
		local requestId -- 106
		local ____hasReturned, ____returnValue -- 106
		local ____try = __TS__AsyncAwaiter(function() -- 106
			requestId = _studio_agent_tool_begin(operation, file, content, projectRoot) -- 107
		end) -- 107
		____try = ____try.catch( -- 107
			____try, -- 107
			function(____, ____error) -- 107
				return __TS__AsyncAwaiter(function() -- 107
					____hasReturned = true -- 108
					____returnValue = { -- 108
						success = false, -- 108
						file = file, -- 108
						failureKind = "tool", -- 108
						message = tostring(____error) -- 108
					} -- 108
					return -- 108
				end) -- 108
			end -- 108
		) -- 108
		__TS__Await(____try) -- 107
		if ____hasReturned then -- 107
			return ____awaiter_resolve(nil, ____returnValue) -- 107
		end -- 107
		__TS__Await(__TS__New( -- 109
			__TS__Promise, -- 109
			function(____, resolve) -- 109
				Director.systemScheduler:schedule(once(function() -- 110
					local deadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 111
					local answer -- 112
					wait(function() -- 113
						if (isCancelled and isCancelled()) == true or App.runningTime >= deadline then -- 113
							return true -- 114
						end -- 114
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 115
						return answer ~= nil -- 116
					end) -- 113
					if (isCancelled and isCancelled()) == true then -- 113
						result = { -- 118
							success = false, -- 118
							file = file, -- 118
							failureKind = "tool", -- 118
							message = "build canceled", -- 118
							interrupted = true -- 118
						} -- 118
					elseif not answer then -- 118
						result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool timed out"} -- 119
					elseif answer.success and type(answer.luaCode) == "string" and __TS__StringTrim(answer.luaCode) ~= "" then -- 119
						if saveLua then -- 119
							local luaFile = Path:replaceExt(file, "lua") -- 122
							result = Content:save(luaFile, answer.luaCode) and ({success = true, file = file}) or ({success = false, file = file, message = "failed to save " .. luaFile}) -- 123
						else -- 123
							result = {success = true, file = file} -- 124
						end -- 124
					else -- 124
						result = {success = false, file = file, message = answer.message or (answer.success and MISSING_LUA_OUTPUT_MESSAGE or "Studio Agent build tool failed")} -- 125
					end -- 125
					resolve(nil) -- 126
				end)) -- 110
			end -- 109
		)) -- 109
		if not result.success and (result.interrupted == true or result.message == "Studio Agent build tool timed out") then -- 109
			if _studio_agent_tool_cancel ~= nil then -- 109
				_studio_agent_tool_cancel(requestId) -- 129
			end -- 129
		end -- 129
		return ____awaiter_resolve(nil, result) -- 129
	end) -- 129
end -- 129
local function isDtsFile(path) -- 43
	return Path:getExt(Path:getName(path)) == "d" -- 44
end -- 43
local function isTiledEditorContent(content) -- 47
	return __TS__StringStartsWith( -- 48
		__TS__StringTrim(content), -- 48
		"<?xml" -- 48
	) -- 48
end -- 47
local function getSupportedBuildKind(path) -- 53
	repeat -- 53
		local ____switch5 = Path:getExt(path) -- 53
		local ____cond5 = ____switch5 == "ts" or ____switch5 == "tsx" -- 53
		if ____cond5 then -- 53
			return "ts" -- 55
		end -- 55
		____cond5 = ____cond5 or ____switch5 == "xml" -- 55
		if ____cond5 then -- 55
			return "xml" -- 56
		end -- 56
		____cond5 = ____cond5 or ____switch5 == "tl" -- 56
		if ____cond5 then -- 56
			return "teal" -- 57
		end -- 57
		____cond5 = ____cond5 or ____switch5 == "lua" -- 57
		if ____cond5 then -- 57
			return "lua" -- 58
		end -- 58
		____cond5 = ____cond5 or ____switch5 == "yue" -- 58
		if ____cond5 then -- 58
			return "yue" -- 59
		end -- 59
		____cond5 = ____cond5 or ____switch5 == "yarn" -- 59
		if ____cond5 then -- 59
			return "yarn" -- 60
		end -- 60
		do -- 60
			return nil -- 61
		end -- 61
	until true -- 61
end -- 53
local function encodeJSON(obj) -- 65
	local text = safeJsonEncode(obj) -- 66
	return text -- 67
end -- 65
local function runSingleNonTsBuild(file, projectRoot, isCancelled) -- 70
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 70
		if type(_studio_agent_tool_begin) == "function" then -- 70
			if not projectRoot then -- 70
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 70
			end -- 70
			local kind = getSupportedBuildKind(file) -- 73
			if kind ~= "teal" and kind ~= "lua" and kind ~= "yarn" and kind ~= "yue" and kind ~= "xml" then -- 73
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = ("Studio Agent " .. (kind or "unknown")) .. " build tool is not connected"}) -- 73
			end -- 73
			local content = Content:load(file) -- 75
			if content == nil then -- 75
				return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to read file"}) -- 75
			end -- 75
			return ____awaiter_resolve( -- 75
				nil, -- 75
				runStudioBuild( -- 80
					file, -- 80
					content, -- 80
					projectRoot, -- 80
					"build-script", -- 80
					kind == "teal", -- 80
					isCancelled -- 80
				) -- 80
			) -- 80
		end -- 80
		return ____awaiter_resolve( -- 80
			nil, -- 80
			__TS__New( -- 82
				__TS__Promise, -- 82
				function(____, resolve) -- 82
					local moduleName = "Script.Dev.WebServer" -- 83
					local ____require_result_0 = require(moduleName) -- 84
					local buildAsync = ____require_result_0.buildAsync -- 84
					Director.systemScheduler:schedule(once(function() -- 85
						local result = buildAsync(file) -- 86
						resolve(nil, result) -- 87
					end)) -- 85
				end -- 82
			) -- 82
		) -- 82
	end) -- 82
end -- 70
local transpileRequestSeq = 0 -- 92
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 93
TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 94
MISSING_LUA_OUTPUT_MESSAGE = "Compiler returned no Lua output" -- 95
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 133
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 133
		if type(_studio_agent_tool_begin) == "function" then -- 133
			if not projectRoot then -- 133
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 133
			end -- 133
			return ____awaiter_resolve( -- 133
				nil, -- 133
				runStudioBuild( -- 141
					file, -- 141
					content, -- 141
					projectRoot, -- 141
					"transpile-ts", -- 141
					true, -- 141
					isCancelled -- 141
				) -- 141
			) -- 141
		end -- 141
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 141
			return ____awaiter_resolve( -- 141
				nil, -- 141
				__TS__New( -- 144
					__TS__Promise, -- 144
					function(____, resolve) -- 144
						local moduleName = "Script.Dev.WebServer" -- 145
						local webServer = require(moduleName) -- 146
						Director.systemScheduler:schedule(once(function() -- 156
							resolve( -- 157
								nil, -- 157
								webServer.transpileTSFile( -- 157
									file, -- 157
									content, -- 157
									projectRoot, -- 157
									nil, -- 157
									isCancelled -- 157
								) -- 157
							) -- 157
						end)) -- 156
					end -- 144
				) -- 144
			) -- 144
		end -- 144
		local done = false -- 161
		local ready = false -- 162
		transpileRequestSeq = transpileRequestSeq + 1 -- 163
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 164
		local result = {success = false, file = file, failureKind = "tool", message = "Web IDE not connected"} -- 165
		if HttpServer.wsConnectionCount == 0 then -- 165
			return ____awaiter_resolve(nil, result) -- 165
		end -- 165
		local listener = Node() -- 174
		listener:gslot( -- 175
			"AppWS", -- 175
			function(event) -- 175
				if event.type ~= "Receive" then -- 175
					return -- 176
				end -- 176
				local res = safeJsonDecode(event.msg) -- 177
				if not res or __TS__ArrayIsArray(res) then -- 177
					return -- 178
				end -- 178
				local payload = res -- 179
				if payload.id ~= requestId then -- 179
					return -- 180
				end -- 180
				if payload.name == "TranspileTSProbe" then -- 180
					ready = payload.success == true -- 182
					return -- 183
				end -- 183
				if payload.name ~= "TranspileTS" then -- 183
					return -- 185
				end -- 185
				if payload.success and type(payload.luaCode) == "string" and __TS__StringTrim(payload.luaCode) ~= "" then -- 185
					local luaFile = Path:replaceExt(file, "lua") -- 187
					if Content:save( -- 187
						luaFile, -- 188
						tostring(payload.luaCode) -- 188
					) then -- 188
						result = {success = true, file = file} -- 189
					else -- 189
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 191
					end -- 191
				else -- 191
					result = { -- 194
						success = false, -- 194
						file = file, -- 194
						message = payload.success and MISSING_LUA_OUTPUT_MESSAGE or tostring(payload.message), -- 194
						failureKind = payload.failureKind == "tool" and "tool" or nil -- 194
					} -- 194
				end -- 194
				done = true -- 196
			end -- 175
		) -- 175
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 198
		local buildPayload = encodeJSON({ -- 199
			name = "TranspileTS", -- 200
			id = requestId, -- 201
			file = file, -- 202
			content = content, -- 203
			projectRoot = projectRoot -- 204
		}) -- 204
		if not probePayload or not buildPayload then -- 204
			listener:removeFromParent() -- 207
			return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "failed to encode transpile request"}) -- 207
		end -- 207
		__TS__Await(__TS__New( -- 210
			__TS__Promise, -- 210
			function(____, resolve) -- 210
				Director.systemScheduler:schedule(once(function() -- 211
					emit("AppWS", "Send", probePayload) -- 212
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 213
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 214
					if not ready then -- 214
						listener:removeFromParent() -- 219
						if (isCancelled and isCancelled()) == true then -- 219
							result = { -- 221
								success = false, -- 221
								file = file, -- 221
								failureKind = "tool", -- 221
								message = "build canceled", -- 221
								interrupted = true -- 221
							} -- 221
						elseif HttpServer.wsConnectionCount == 0 then -- 221
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 223
						else -- 223
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpiler is not ready"} -- 225
						end -- 225
						resolve(nil) -- 227
						return -- 228
					end -- 228
					emit("AppWS", "Send", buildPayload) -- 230
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 231
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 232
					if not done then -- 232
						listener:removeFromParent() -- 237
						if (isCancelled and isCancelled()) == true then -- 237
							result = { -- 239
								success = false, -- 239
								file = file, -- 239
								failureKind = "tool", -- 239
								message = "build canceled", -- 239
								interrupted = true -- 239
							} -- 239
						elseif HttpServer.wsConnectionCount == 0 then -- 239
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 241
						else -- 241
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpile timed out"} -- 243
						end -- 243
					end -- 243
					resolve(nil) -- 246
				end)) -- 211
			end -- 210
		)) -- 210
		return ____awaiter_resolve(nil, result) -- 210
	end) -- 210
end -- 133
local function finalizeBuildResult(workDir, messages) -- 252
	local normalized = __TS__ArrayMap( -- 253
		messages, -- 253
		function(____, m) return __TS__ObjectAssign( -- 253
			{}, -- 253
			m, -- 253
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 253
		) end -- 253
	) -- 253
	local total = #normalized -- 254
	if total == 0 then -- 254
		return { -- 255
			success = false, -- 255
			message = "No code files were compiled; declarations and skipped files do not count as a build.", -- 255
			total = 0, -- 255
			passed = 0, -- 255
			failed = 0 -- 255
		} -- 255
	end -- 255
	local failed = 0 -- 256
	do -- 256
		local i = 0 -- 257
		while i < #normalized do -- 257
			if not normalized[i + 1].success then -- 257
				failed = failed + 1 -- 258
			end -- 258
			i = i + 1 -- 257
		end -- 257
	end -- 257
	local passed = total - failed -- 260
	if failed > 0 then -- 260
		local interrupted = __TS__ArraySome( -- 262
			normalized, -- 262
			function(____, message) return not message.success and message.interrupted == true end -- 262
		) -- 262
		local toolFailures = __TS__ArrayFilter( -- 263
			normalized, -- 263
			function(____, m) return not m.success and m.failureKind == "tool" end -- 263
		) -- 263
		return { -- 264
			success = false, -- 265
			message = #toolFailures > 0 and table.concat( -- 266
				__TS__ArrayMap( -- 266
					toolFailures, -- 266
					function(____, m) return m.message end -- 266
				), -- 266
				"; " -- 266
			) or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 266
			total = total, -- 267
			passed = passed, -- 268
			failed = failed, -- 269
			messages = normalized, -- 270
			interrupted = interrupted or nil, -- 271
			failureKind = #toolFailures > 0 and "tool" or nil -- 272
		} -- 272
	end -- 272
	return { -- 275
		success = true, -- 276
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 277
		total = total, -- 278
		passed = passed, -- 279
		failed = 0, -- 280
		messages = normalized -- 281
	} -- 281
end -- 252
function ____exports.build(req) -- 285
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 285
		local ____this_18 -- 285
		____this_18 = req -- 286
		local ____opt_17 = ____this_18.isCancelled -- 286
		if (____opt_17 and ____opt_17(____this_18)) == true then -- 286
			return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "Build canceled.", interrupted = true}) -- 286
		end -- 286
		local targetRel = req.path or "" -- 289
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 290
		if not target then -- 290
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 290
		end -- 290
		if not Content:exist(target) then -- 290
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 290
		end -- 290
		local messages = {} -- 297
		local godotProject = findGodotProject(req.workDir, target) -- 300
		if godotProject ~= nil then -- 300
			local result = __TS__Await(buildGodotProject(godotProject, req.isCancelled)) -- 302
			__TS__ArrayPushArray(messages, result.messages or ({result})) -- 303
			if not result.success then -- 303
				return ____awaiter_resolve( -- 303
					nil, -- 303
					finalizeBuildResult(req.workDir, messages) -- 304
				) -- 304
			end -- 304
		end -- 304
		if not Content:isdir(target) then -- 304
			local kind = getSupportedBuildKind(target) -- 307
			if not kind then -- 307
				if godotProject ~= nil then -- 307
					return ____awaiter_resolve( -- 307
						nil, -- 307
						finalizeBuildResult(req.workDir, messages) -- 309
					) -- 309
				end -- 309
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 309
			end -- 309
			if kind == "ts" then -- 309
				local content = Content:load(target) -- 313
				if content == nil then -- 313
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 313
				end -- 313
				if isTiledEditorContent(content) then -- 313
					Log("Info", "[build] skip tiled editor file=" .. target) -- 318
					return ____awaiter_resolve( -- 318
						nil, -- 318
						finalizeBuildResult(req.workDir, messages) -- 319
					) -- 319
				end -- 319
				if not sendWebIDEFileUpdate(target, true, content) then -- 319
					return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "failed to encode UpdateFile request"}) -- 319
				end -- 319
				if not isDtsFile(target) then -- 319
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 325
				end -- 325
			else -- 325
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target, req.workDir, req.isCancelled)) -- 328
			end -- 328
			Log( -- 330
				"Info", -- 330
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 330
			) -- 330
			return ____awaiter_resolve( -- 330
				nil, -- 330
				finalizeBuildResult(req.workDir, messages) -- 331
			) -- 331
		end -- 331
		local listResult = listFiles({ -- 333
			workDir = req.workDir, -- 334
			path = targetRel, -- 335
			globs = __TS__ArrayMap( -- 336
				codeExtensions, -- 336
				function(____, e) return "**/*" .. e end -- 336
			), -- 336
			maxEntries = 10000 -- 337
		}) -- 337
		local relFiles = listResult.success and listResult.files or ({}) -- 340
		local tsFileData = {} -- 341
		local buildQueue = {} -- 342
		for ____, rel in ipairs(relFiles) do -- 343
			do -- 343
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 344
				if Path:getFilename(file) == "project.godot" and Path:getPath(file) ~= godotProject then -- 344
					local result = __TS__Await(buildGodotProject( -- 346
						Path:getPath(file), -- 346
						req.isCancelled -- 346
					)) -- 346
					__TS__ArrayPushArray(messages, result.messages or ({result})) -- 347
					local ____this_20 -- 347
					____this_20 = req -- 348
					local ____opt_19 = ____this_20.isCancelled -- 348
					if (____opt_19 and ____opt_19(____this_20)) == true then -- 348
						return ____awaiter_resolve( -- 348
							nil, -- 348
							finalizeBuildResult(req.workDir, messages) -- 348
						) -- 348
					end -- 348
				end -- 348
				local kind = getSupportedBuildKind(file) -- 350
				if not kind then -- 350
					goto __continue85 -- 351
				end -- 351
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 352
				if kind ~= "ts" then -- 352
					goto __continue85 -- 354
				end -- 354
				local content = Content:load(file) -- 356
				if content == nil then -- 356
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 358
					goto __continue85 -- 359
				end -- 359
				if isTiledEditorContent(content) then -- 359
					Log("Info", "[build] skip tiled editor file=" .. file) -- 362
					goto __continue85 -- 363
				end -- 363
				tsFileData[file] = content -- 365
			end -- 365
			::__continue85:: -- 365
		end -- 365
		do -- 365
			local i = 0 -- 367
			while i < #buildQueue do -- 367
				do -- 367
					local ____this_22 -- 367
					____this_22 = req -- 368
					local ____opt_21 = ____this_22.isCancelled -- 368
					if (____opt_21 and ____opt_21(____this_22)) == true then -- 368
						return ____awaiter_resolve(nil, { -- 368
							success = false, -- 369
							failureKind = "tool", -- 369
							message = "Build canceled.", -- 369
							messages = messages, -- 369
							interrupted = true -- 369
						}) -- 369
					end -- 369
					local ____buildQueue_index_23 = buildQueue[i + 1] -- 371
					local file = ____buildQueue_index_23.file -- 371
					local kind = ____buildQueue_index_23.kind -- 371
					if kind == "ts" then -- 371
						local content = tsFileData[file] -- 373
						if content == nil or isDtsFile(file) then -- 373
							goto __continue94 -- 375
						end -- 375
						if not sendWebIDEFileUpdate(file, true, content) then -- 375
							messages[#messages + 1] = {success = false, file = file, failureKind = "tool", message = "failed to encode UpdateFile request"} -- 378
							goto __continue94 -- 379
						end -- 379
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 381
						goto __continue94 -- 382
					end -- 382
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file, req.workDir, req.isCancelled)) -- 384
				end -- 384
				::__continue94:: -- 384
				i = i + 1 -- 367
			end -- 367
		end -- 367
		if #messages == 0 then -- 367
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 387
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 387
		end -- 387
		Log( -- 390
			"Info", -- 390
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 390
		) -- 390
		return ____awaiter_resolve( -- 390
			nil, -- 390
			finalizeBuildResult(req.workDir, messages) -- 391
		) -- 391
	end) -- 391
end -- 285
return ____exports -- 285