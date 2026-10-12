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
local ____Workspace = require("Agent.Tool.Workspace") -- 5
local resolveWorkspaceSearchPath = ____Workspace.resolveWorkspaceSearchPath -- 6
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 7
local listFiles = ____Workspace.listFiles -- 8
local codeExtensions = ____Workspace.codeExtensions -- 9
function runStudioBuild(file, content, projectRoot, operation, saveLua, isCancelled) -- 101
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 101
		local result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool is unavailable"} -- 102
		if type(_studio_agent_tool_begin) ~= "function" or type(_studio_agent_tool_poll) ~= "function" then -- 102
			return ____awaiter_resolve(nil, result) -- 102
		end -- 102
		local requestId -- 104
		local ____hasReturned, ____returnValue -- 104
		local ____try = __TS__AsyncAwaiter(function() -- 104
			requestId = _studio_agent_tool_begin(operation, file, content, projectRoot) -- 105
		end) -- 105
		____try = ____try.catch( -- 105
			____try, -- 105
			function(____, ____error) -- 105
				return __TS__AsyncAwaiter(function() -- 105
					____hasReturned = true -- 106
					____returnValue = { -- 106
						success = false, -- 106
						file = file, -- 106
						failureKind = "tool", -- 106
						message = tostring(____error) -- 106
					} -- 106
					return -- 106
				end) -- 106
			end -- 106
		) -- 106
		__TS__Await(____try) -- 105
		if ____hasReturned then -- 105
			return ____awaiter_resolve(nil, ____returnValue) -- 105
		end -- 105
		__TS__Await(__TS__New( -- 107
			__TS__Promise, -- 107
			function(____, resolve) -- 107
				Director.systemScheduler:schedule(once(function() -- 108
					local deadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 109
					local answer -- 110
					wait(function() -- 111
						if (isCancelled and isCancelled()) == true or App.runningTime >= deadline then -- 111
							return true -- 112
						end -- 112
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 113
						return answer ~= nil -- 114
					end) -- 111
					if (isCancelled and isCancelled()) == true then -- 111
						result = { -- 116
							success = false, -- 116
							file = file, -- 116
							failureKind = "tool", -- 116
							message = "build canceled", -- 116
							interrupted = true -- 116
						} -- 116
					elseif not answer then -- 116
						result = {success = false, file = file, failureKind = "tool", message = "Studio Agent build tool timed out"} -- 117
					elseif answer.success and type(answer.luaCode) == "string" and __TS__StringTrim(answer.luaCode) ~= "" then -- 117
						if saveLua then -- 117
							local luaFile = Path:replaceExt(file, "lua") -- 120
							result = Content:save(luaFile, answer.luaCode) and ({success = true, file = file}) or ({success = false, file = file, message = "failed to save " .. luaFile}) -- 121
						else -- 121
							result = {success = true, file = file} -- 122
						end -- 122
					else -- 122
						result = {success = false, file = file, message = answer.message or (answer.success and MISSING_LUA_OUTPUT_MESSAGE or "Studio Agent build tool failed")} -- 123
					end -- 123
					resolve(nil) -- 124
				end)) -- 108
			end -- 107
		)) -- 107
		if not result.success and (result.interrupted == true or result.message == "Studio Agent build tool timed out") then -- 107
			if _studio_agent_tool_cancel ~= nil then -- 107
				_studio_agent_tool_cancel(requestId) -- 127
			end -- 127
		end -- 127
		return ____awaiter_resolve(nil, result) -- 127
	end) -- 127
end -- 127
local function isDtsFile(path) -- 41
	return Path:getExt(Path:getName(path)) == "d" -- 42
end -- 41
local function isTiledEditorContent(content) -- 45
	return __TS__StringStartsWith( -- 46
		__TS__StringTrim(content), -- 46
		"<?xml" -- 46
	) -- 46
end -- 45
local function getSupportedBuildKind(path) -- 51
	repeat -- 51
		local ____switch5 = Path:getExt(path) -- 51
		local ____cond5 = ____switch5 == "ts" or ____switch5 == "tsx" -- 51
		if ____cond5 then -- 51
			return "ts" -- 53
		end -- 53
		____cond5 = ____cond5 or ____switch5 == "xml" -- 53
		if ____cond5 then -- 53
			return "xml" -- 54
		end -- 54
		____cond5 = ____cond5 or ____switch5 == "tl" -- 54
		if ____cond5 then -- 54
			return "teal" -- 55
		end -- 55
		____cond5 = ____cond5 or ____switch5 == "lua" -- 55
		if ____cond5 then -- 55
			return "lua" -- 56
		end -- 56
		____cond5 = ____cond5 or ____switch5 == "yue" -- 56
		if ____cond5 then -- 56
			return "yue" -- 57
		end -- 57
		____cond5 = ____cond5 or ____switch5 == "yarn" -- 57
		if ____cond5 then -- 57
			return "yarn" -- 58
		end -- 58
		do -- 58
			return nil -- 59
		end -- 59
	until true -- 59
end -- 51
local function encodeJSON(obj) -- 63
	local text = safeJsonEncode(obj) -- 64
	return text -- 65
end -- 63
local function runSingleNonTsBuild(file, projectRoot, isCancelled) -- 68
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 68
		if type(_studio_agent_tool_begin) == "function" then -- 68
			if not projectRoot then -- 68
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 68
			end -- 68
			local kind = getSupportedBuildKind(file) -- 71
			if kind ~= "teal" and kind ~= "lua" and kind ~= "yarn" and kind ~= "yue" and kind ~= "xml" then -- 71
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = ("Studio Agent " .. (kind or "unknown")) .. " build tool is not connected"}) -- 71
			end -- 71
			local content = Content:load(file) -- 73
			if content == nil then -- 73
				return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to read file"}) -- 73
			end -- 73
			return ____awaiter_resolve( -- 73
				nil, -- 73
				runStudioBuild( -- 78
					file, -- 78
					content, -- 78
					projectRoot, -- 78
					"build-script", -- 78
					kind == "teal", -- 78
					isCancelled -- 78
				) -- 78
			) -- 78
		end -- 78
		return ____awaiter_resolve( -- 78
			nil, -- 78
			__TS__New( -- 80
				__TS__Promise, -- 80
				function(____, resolve) -- 80
					local moduleName = "Script.Dev.WebServer" -- 81
					local ____require_result_0 = require(moduleName) -- 82
					local buildAsync = ____require_result_0.buildAsync -- 82
					Director.systemScheduler:schedule(once(function() -- 83
						local result = buildAsync(file) -- 84
						resolve(nil, result) -- 85
					end)) -- 83
				end -- 80
			) -- 80
		) -- 80
	end) -- 80
end -- 68
local transpileRequestSeq = 0 -- 90
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 91
TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 92
MISSING_LUA_OUTPUT_MESSAGE = "Compiler returned no Lua output" -- 93
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 131
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 131
		if type(_studio_agent_tool_begin) == "function" then -- 131
			if not projectRoot then -- 131
				return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "Studio project root is unavailable"}) -- 131
			end -- 131
			return ____awaiter_resolve( -- 131
				nil, -- 131
				runStudioBuild( -- 139
					file, -- 139
					content, -- 139
					projectRoot, -- 139
					"transpile-ts", -- 139
					true, -- 139
					isCancelled -- 139
				) -- 139
			) -- 139
		end -- 139
		if App.platform == "Android" then -- 139
			return ____awaiter_resolve( -- 139
				nil, -- 139
				__TS__New( -- 142
					__TS__Promise, -- 142
					function(____, resolve) -- 142
						local moduleName = "Script.Dev.WebServer" -- 143
						local webServer = require(moduleName) -- 144
						Director.systemScheduler:schedule(once(function() -- 154
							resolve( -- 155
								nil, -- 155
								webServer.transpileTSFile( -- 155
									file, -- 155
									content, -- 155
									projectRoot, -- 155
									nil, -- 155
									isCancelled -- 155
								) -- 155
							) -- 155
						end)) -- 154
					end -- 142
				) -- 142
			) -- 142
		end -- 142
		local done = false -- 159
		local ready = false -- 160
		transpileRequestSeq = transpileRequestSeq + 1 -- 161
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 162
		local result = {success = false, file = file, failureKind = "tool", message = "Web IDE not connected"} -- 163
		if HttpServer.wsConnectionCount == 0 then -- 163
			return ____awaiter_resolve(nil, result) -- 163
		end -- 163
		local listener = Node() -- 172
		listener:gslot( -- 173
			"AppWS", -- 173
			function(event) -- 173
				if event.type ~= "Receive" then -- 173
					return -- 174
				end -- 174
				local res = safeJsonDecode(event.msg) -- 175
				if not res or __TS__ArrayIsArray(res) then -- 175
					return -- 176
				end -- 176
				local payload = res -- 177
				if payload.id ~= requestId then -- 177
					return -- 178
				end -- 178
				if payload.name == "TranspileTSProbe" then -- 178
					ready = true -- 180
					return -- 181
				end -- 181
				if payload.name ~= "TranspileTS" then -- 181
					return -- 183
				end -- 183
				if payload.success and type(payload.luaCode) == "string" and __TS__StringTrim(payload.luaCode) ~= "" then -- 183
					local luaFile = Path:replaceExt(file, "lua") -- 185
					if Content:save( -- 185
						luaFile, -- 186
						tostring(payload.luaCode) -- 186
					) then -- 186
						result = {success = true, file = file} -- 187
					else -- 187
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 189
					end -- 189
				else -- 189
					result = { -- 192
						success = false, -- 192
						file = file, -- 192
						message = payload.success and MISSING_LUA_OUTPUT_MESSAGE or tostring(payload.message), -- 192
						failureKind = payload.failureKind == "tool" and "tool" or nil -- 192
					} -- 192
				end -- 192
				done = true -- 194
			end -- 173
		) -- 173
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 196
		local buildPayload = encodeJSON({ -- 197
			name = "TranspileTS", -- 198
			id = requestId, -- 199
			file = file, -- 200
			content = content, -- 201
			projectRoot = projectRoot -- 202
		}) -- 202
		if not probePayload or not buildPayload then -- 202
			listener:removeFromParent() -- 205
			return ____awaiter_resolve(nil, {success = false, file = file, failureKind = "tool", message = "failed to encode transpile request"}) -- 205
		end -- 205
		__TS__Await(__TS__New( -- 208
			__TS__Promise, -- 208
			function(____, resolve) -- 208
				Director.systemScheduler:schedule(once(function() -- 209
					emit("AppWS", "Send", probePayload) -- 210
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 211
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 212
					if not ready then -- 212
						listener:removeFromParent() -- 217
						if (isCancelled and isCancelled()) == true then -- 217
							result = { -- 219
								success = false, -- 219
								file = file, -- 219
								failureKind = "tool", -- 219
								message = "build canceled", -- 219
								interrupted = true -- 219
							} -- 219
						elseif HttpServer.wsConnectionCount == 0 then -- 219
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 221
						else -- 221
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpiler is not ready"} -- 223
						end -- 223
						resolve(nil) -- 225
						return -- 226
					end -- 226
					emit("AppWS", "Send", buildPayload) -- 228
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 229
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 230
					if not done then -- 230
						listener:removeFromParent() -- 235
						if (isCancelled and isCancelled()) == true then -- 235
							result = { -- 237
								success = false, -- 237
								file = file, -- 237
								failureKind = "tool", -- 237
								message = "build canceled", -- 237
								interrupted = true -- 237
							} -- 237
						elseif HttpServer.wsConnectionCount == 0 then -- 237
							result = {success = false, file = file, failureKind = "tool", message = "Web IDE disconnected"} -- 239
						else -- 239
							result = {success = false, file = file, failureKind = "tool", message = "TypeScript transpile timed out"} -- 241
						end -- 241
					end -- 241
					resolve(nil) -- 244
				end)) -- 209
			end -- 208
		)) -- 208
		return ____awaiter_resolve(nil, result) -- 208
	end) -- 208
end -- 131
local function finalizeBuildResult(workDir, messages) -- 250
	local normalized = __TS__ArrayMap( -- 251
		messages, -- 251
		function(____, m) return __TS__ObjectAssign( -- 251
			{}, -- 251
			m, -- 251
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 251
		) end -- 251
	) -- 251
	local total = #normalized -- 252
	if total == 0 then -- 252
		return { -- 253
			success = false, -- 253
			message = "No code files were compiled; declarations and skipped files do not count as a build.", -- 253
			total = 0, -- 253
			passed = 0, -- 253
			failed = 0 -- 253
		} -- 253
	end -- 253
	local failed = 0 -- 254
	do -- 254
		local i = 0 -- 255
		while i < #normalized do -- 255
			if not normalized[i + 1].success then -- 255
				failed = failed + 1 -- 256
			end -- 256
			i = i + 1 -- 255
		end -- 255
	end -- 255
	local passed = total - failed -- 258
	if failed > 0 then -- 258
		local interrupted = __TS__ArraySome( -- 260
			normalized, -- 260
			function(____, message) return not message.success and message.interrupted == true end -- 260
		) -- 260
		local toolFailures = __TS__ArrayFilter( -- 261
			normalized, -- 261
			function(____, m) return not m.success and m.failureKind == "tool" end -- 261
		) -- 261
		return { -- 262
			success = false, -- 263
			message = #toolFailures > 0 and table.concat( -- 264
				__TS__ArrayMap( -- 264
					toolFailures, -- 264
					function(____, m) return m.message end -- 264
				), -- 264
				"; " -- 264
			) or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 264
			total = total, -- 265
			passed = passed, -- 266
			failed = failed, -- 267
			messages = normalized, -- 268
			interrupted = interrupted or nil, -- 269
			failureKind = #toolFailures > 0 and "tool" or nil -- 270
		} -- 270
	end -- 270
	return { -- 273
		success = true, -- 274
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 275
		total = total, -- 276
		passed = passed, -- 277
		failed = 0, -- 278
		messages = normalized -- 279
	} -- 279
end -- 250
function ____exports.build(req) -- 283
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 283
		local ____this_18 -- 283
		____this_18 = req -- 284
		local ____opt_17 = ____this_18.isCancelled -- 284
		if (____opt_17 and ____opt_17(____this_18)) == true then -- 284
			return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "Build canceled.", interrupted = true}) -- 284
		end -- 284
		local targetRel = req.path or "" -- 287
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 288
		if not target then -- 288
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 288
		end -- 288
		if not Content:exist(target) then -- 288
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 288
		end -- 288
		local messages = {} -- 295
		if not Content:isdir(target) then -- 295
			local kind = getSupportedBuildKind(target) -- 297
			if not kind then -- 297
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 297
			end -- 297
			if kind == "ts" then -- 297
				local content = Content:load(target) -- 302
				if content == nil then -- 302
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 302
				end -- 302
				if isTiledEditorContent(content) then -- 302
					Log("Info", "[build] skip tiled editor file=" .. target) -- 307
					return ____awaiter_resolve( -- 307
						nil, -- 307
						finalizeBuildResult(req.workDir, messages) -- 308
					) -- 308
				end -- 308
				if not sendWebIDEFileUpdate(target, true, content) then -- 308
					return ____awaiter_resolve(nil, {success = false, failureKind = "tool", message = "failed to encode UpdateFile request"}) -- 308
				end -- 308
				if not isDtsFile(target) then -- 308
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 314
				end -- 314
			else -- 314
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target, req.workDir, req.isCancelled)) -- 317
			end -- 317
			Log( -- 319
				"Info", -- 319
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 319
			) -- 319
			return ____awaiter_resolve( -- 319
				nil, -- 319
				finalizeBuildResult(req.workDir, messages) -- 320
			) -- 320
		end -- 320
		local listResult = listFiles({ -- 322
			workDir = req.workDir, -- 323
			path = targetRel, -- 324
			globs = __TS__ArrayMap( -- 325
				codeExtensions, -- 325
				function(____, e) return "**/*" .. e end -- 325
			), -- 325
			maxEntries = 10000 -- 326
		}) -- 326
		local relFiles = listResult.success and listResult.files or ({}) -- 329
		local tsFileData = {} -- 330
		local buildQueue = {} -- 331
		for ____, rel in ipairs(relFiles) do -- 332
			do -- 332
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 333
				local kind = getSupportedBuildKind(file) -- 334
				if not kind then -- 334
					goto __continue82 -- 335
				end -- 335
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 336
				if kind ~= "ts" then -- 336
					goto __continue82 -- 338
				end -- 338
				local content = Content:load(file) -- 340
				if content == nil then -- 340
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 342
					goto __continue82 -- 343
				end -- 343
				if isTiledEditorContent(content) then -- 343
					Log("Info", "[build] skip tiled editor file=" .. file) -- 346
					goto __continue82 -- 347
				end -- 347
				tsFileData[file] = content -- 349
			end -- 349
			::__continue82:: -- 349
		end -- 349
		do -- 349
			local i = 0 -- 351
			while i < #buildQueue do -- 351
				do -- 351
					local ____this_20 -- 351
					____this_20 = req -- 352
					local ____opt_19 = ____this_20.isCancelled -- 352
					if (____opt_19 and ____opt_19(____this_20)) == true then -- 352
						return ____awaiter_resolve(nil, { -- 352
							success = false, -- 353
							failureKind = "tool", -- 353
							message = "Build canceled.", -- 353
							messages = messages, -- 353
							interrupted = true -- 353
						}) -- 353
					end -- 353
					local ____buildQueue_index_21 = buildQueue[i + 1] -- 355
					local file = ____buildQueue_index_21.file -- 355
					local kind = ____buildQueue_index_21.kind -- 355
					if kind == "ts" then -- 355
						local content = tsFileData[file] -- 357
						if content == nil or isDtsFile(file) then -- 357
							goto __continue89 -- 359
						end -- 359
						if not sendWebIDEFileUpdate(file, true, content) then -- 359
							messages[#messages + 1] = {success = false, file = file, failureKind = "tool", message = "failed to encode UpdateFile request"} -- 362
							goto __continue89 -- 363
						end -- 363
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 365
						goto __continue89 -- 366
					end -- 366
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file, req.workDir, req.isCancelled)) -- 368
				end -- 368
				::__continue89:: -- 368
				i = i + 1 -- 351
			end -- 351
		end -- 351
		if #messages == 0 then -- 351
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 371
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 371
		end -- 371
		Log( -- 374
			"Info", -- 374
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 374
		) -- 374
		return ____awaiter_resolve( -- 374
			nil, -- 374
			finalizeBuildResult(req.workDir, messages) -- 375
		) -- 375
	end) -- 375
end -- 283
return ____exports -- 283