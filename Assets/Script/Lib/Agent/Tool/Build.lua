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
local ____exports = {} -- 1
local runStudioBuild, TRANSPILE_BUILD_TIMEOUT_SECONDS -- 1
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
function runStudioBuild(file, content, projectRoot, operation, saveLua, isCancelled) -- 98
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 98
		local result = {success = false, file = file, message = "Studio Agent build tool is unavailable"} -- 99
		if type(_studio_agent_tool_begin) ~= "function" or type(_studio_agent_tool_poll) ~= "function" then -- 99
			return ____awaiter_resolve(nil, result) -- 99
		end -- 99
		local requestId -- 101
		local ____hasReturned, ____returnValue -- 101
		local ____try = __TS__AsyncAwaiter(function() -- 101
			requestId = _studio_agent_tool_begin(operation, file, content, projectRoot) -- 102
		end) -- 102
		____try = ____try.catch( -- 102
			____try, -- 102
			function(____, ____error) -- 102
				return __TS__AsyncAwaiter(function() -- 102
					____hasReturned = true -- 103
					____returnValue = { -- 103
						success = false, -- 103
						file = file, -- 103
						message = tostring(____error) -- 103
					} -- 103
					return -- 103
				end) -- 103
			end -- 103
		) -- 103
		__TS__Await(____try) -- 102
		if ____hasReturned then -- 102
			return ____awaiter_resolve(nil, ____returnValue) -- 102
		end -- 102
		__TS__Await(__TS__New( -- 104
			__TS__Promise, -- 104
			function(____, resolve) -- 104
				Director.systemScheduler:schedule(once(function() -- 105
					local deadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 106
					local answer -- 107
					wait(function() -- 108
						if (isCancelled and isCancelled()) == true or App.runningTime >= deadline then -- 108
							return true -- 109
						end -- 109
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 110
						return answer ~= nil -- 111
					end) -- 108
					if (isCancelled and isCancelled()) == true then -- 108
						result = {success = false, file = file, message = "build canceled", interrupted = true} -- 113
					elseif not answer then -- 113
						result = {success = false, file = file, message = "Studio Agent build tool timed out"} -- 114
					elseif answer.success and type(answer.luaCode) == "string" then -- 114
						if saveLua then -- 114
							local luaFile = Path:replaceExt(file, "lua") -- 117
							result = Content:save(luaFile, answer.luaCode) and ({success = true, file = file}) or ({success = false, file = file, message = "failed to save " .. luaFile}) -- 118
						else -- 118
							result = {success = true, file = file} -- 119
						end -- 119
					else -- 119
						result = {success = false, file = file, message = answer.message or "Studio Agent build tool failed"} -- 120
					end -- 120
					resolve(nil) -- 121
				end)) -- 105
			end -- 104
		)) -- 104
		if not result.success and (result.interrupted == true or result.message == "Studio Agent build tool timed out") then -- 104
			if _studio_agent_tool_cancel ~= nil then -- 104
				_studio_agent_tool_cancel(requestId) -- 124
			end -- 124
		end -- 124
		return ____awaiter_resolve(nil, result) -- 124
	end) -- 124
end -- 124
local function isDtsFile(path) -- 39
	return Path:getExt(Path:getName(path)) == "d" -- 40
end -- 39
local function isTiledEditorContent(content) -- 43
	return __TS__StringStartsWith( -- 44
		__TS__StringTrim(content), -- 44
		"<?xml" -- 44
	) -- 44
end -- 43
local function getSupportedBuildKind(path) -- 49
	repeat -- 49
		local ____switch5 = Path:getExt(path) -- 49
		local ____cond5 = ____switch5 == "ts" or ____switch5 == "tsx" -- 49
		if ____cond5 then -- 49
			return "ts" -- 51
		end -- 51
		____cond5 = ____cond5 or ____switch5 == "xml" -- 51
		if ____cond5 then -- 51
			return "xml" -- 52
		end -- 52
		____cond5 = ____cond5 or ____switch5 == "tl" -- 52
		if ____cond5 then -- 52
			return "teal" -- 53
		end -- 53
		____cond5 = ____cond5 or ____switch5 == "lua" -- 53
		if ____cond5 then -- 53
			return "lua" -- 54
		end -- 54
		____cond5 = ____cond5 or ____switch5 == "yue" -- 54
		if ____cond5 then -- 54
			return "yue" -- 55
		end -- 55
		____cond5 = ____cond5 or ____switch5 == "yarn" -- 55
		if ____cond5 then -- 55
			return "yarn" -- 56
		end -- 56
		do -- 56
			return nil -- 57
		end -- 57
	until true -- 57
end -- 49
local function encodeJSON(obj) -- 61
	local text = safeJsonEncode(obj) -- 62
	return text -- 63
end -- 61
local function runSingleNonTsBuild(file, projectRoot, isCancelled) -- 66
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 66
		if type(_studio_agent_tool_begin) == "function" then -- 66
			if not projectRoot then -- 66
				return ____awaiter_resolve(nil, {success = false, file = file, message = "Studio project root is unavailable"}) -- 66
			end -- 66
			local kind = getSupportedBuildKind(file) -- 69
			if kind ~= "teal" and kind ~= "lua" and kind ~= "yarn" and kind ~= "yue" and kind ~= "xml" then -- 69
				return ____awaiter_resolve(nil, {success = false, file = file, message = ("Studio Agent " .. (kind or "unknown")) .. " build tool is not connected"}) -- 69
			end -- 69
			local content = Content:load(file) -- 71
			if content == nil then -- 71
				return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to read file"}) -- 71
			end -- 71
			return ____awaiter_resolve( -- 71
				nil, -- 71
				runStudioBuild( -- 76
					file, -- 76
					content, -- 76
					projectRoot, -- 76
					"build-script", -- 76
					kind == "teal", -- 76
					isCancelled -- 76
				) -- 76
			) -- 76
		end -- 76
		return ____awaiter_resolve( -- 76
			nil, -- 76
			__TS__New( -- 78
				__TS__Promise, -- 78
				function(____, resolve) -- 78
					local moduleName = "Script.Dev.WebServer" -- 79
					local ____require_result_0 = require(moduleName) -- 80
					local buildAsync = ____require_result_0.buildAsync -- 80
					Director.systemScheduler:schedule(once(function() -- 81
						local result = buildAsync(file) -- 82
						resolve(nil, result) -- 83
					end)) -- 81
				end -- 78
			) -- 78
		) -- 78
	end) -- 78
end -- 66
local transpileRequestSeq = 0 -- 88
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 89
TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 90
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 128
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 128
		if type(_studio_agent_tool_begin) == "function" then -- 128
			if not projectRoot then -- 128
				return ____awaiter_resolve(nil, {success = false, file = file, message = "Studio project root is unavailable"}) -- 128
			end -- 128
			return ____awaiter_resolve( -- 128
				nil, -- 128
				runStudioBuild( -- 136
					file, -- 136
					content, -- 136
					projectRoot, -- 136
					"transpile-ts", -- 136
					true, -- 136
					isCancelled -- 136
				) -- 136
			) -- 136
		end -- 136
		if App.platform == "Android" then -- 136
			return ____awaiter_resolve( -- 136
				nil, -- 136
				__TS__New( -- 139
					__TS__Promise, -- 139
					function(____, resolve) -- 139
						local moduleName = "Script.Dev.WebServer" -- 140
						local webServer = require(moduleName) -- 141
						Director.systemScheduler:schedule(once(function() -- 151
							resolve( -- 152
								nil, -- 152
								webServer.transpileTSFile( -- 152
									file, -- 152
									content, -- 152
									projectRoot, -- 152
									nil, -- 152
									isCancelled -- 152
								) -- 152
							) -- 152
						end)) -- 151
					end -- 139
				) -- 139
			) -- 139
		end -- 139
		local done = false -- 156
		local ready = false -- 157
		transpileRequestSeq = transpileRequestSeq + 1 -- 158
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 159
		local result = {success = false, file = file, message = "Web IDE not connected"} -- 160
		if HttpServer.wsConnectionCount == 0 then -- 160
			return ____awaiter_resolve(nil, result) -- 160
		end -- 160
		local listener = Node() -- 168
		listener:gslot( -- 169
			"AppWS", -- 169
			function(event) -- 169
				if event.type ~= "Receive" then -- 169
					return -- 170
				end -- 170
				local res = safeJsonDecode(event.msg) -- 171
				if not res or __TS__ArrayIsArray(res) then -- 171
					return -- 172
				end -- 172
				local payload = res -- 173
				if payload.id ~= requestId then -- 173
					return -- 174
				end -- 174
				if payload.name == "TranspileTSProbe" then -- 174
					ready = true -- 176
					return -- 177
				end -- 177
				if payload.name ~= "TranspileTS" then -- 177
					return -- 179
				end -- 179
				if payload.success then -- 179
					local luaFile = Path:replaceExt(file, "lua") -- 181
					if Content:save( -- 181
						luaFile, -- 182
						tostring(payload.luaCode) -- 182
					) then -- 182
						result = {success = true, file = file} -- 183
					else -- 183
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 185
					end -- 185
				else -- 185
					result = { -- 188
						success = false, -- 188
						file = file, -- 188
						message = tostring(payload.message) -- 188
					} -- 188
				end -- 188
				done = true -- 190
			end -- 169
		) -- 169
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 192
		local buildPayload = encodeJSON({ -- 193
			name = "TranspileTS", -- 194
			id = requestId, -- 195
			file = file, -- 196
			content = content, -- 197
			projectRoot = projectRoot -- 198
		}) -- 198
		if not probePayload or not buildPayload then -- 198
			listener:removeFromParent() -- 201
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 201
		end -- 201
		__TS__Await(__TS__New( -- 204
			__TS__Promise, -- 204
			function(____, resolve) -- 204
				Director.systemScheduler:schedule(once(function() -- 205
					emit("AppWS", "Send", probePayload) -- 206
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 207
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 208
					if not ready then -- 208
						listener:removeFromParent() -- 213
						if (isCancelled and isCancelled()) == true then -- 213
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 215
						elseif HttpServer.wsConnectionCount == 0 then -- 215
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 217
						else -- 217
							result = {success = false, file = file, message = "TypeScript transpiler is not ready"} -- 219
						end -- 219
						resolve(nil) -- 221
						return -- 222
					end -- 222
					emit("AppWS", "Send", buildPayload) -- 224
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 225
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 226
					if not done then -- 226
						listener:removeFromParent() -- 231
						if (isCancelled and isCancelled()) == true then -- 231
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 233
						elseif HttpServer.wsConnectionCount == 0 then -- 233
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 235
						else -- 235
							result = {success = false, file = file, message = "TypeScript transpile timed out"} -- 237
						end -- 237
					end -- 237
					resolve(nil) -- 240
				end)) -- 205
			end -- 204
		)) -- 204
		return ____awaiter_resolve(nil, result) -- 204
	end) -- 204
end -- 128
local function finalizeBuildResult(workDir, messages) -- 246
	local normalized = __TS__ArrayMap( -- 247
		messages, -- 247
		function(____, m) return m.success and __TS__ObjectAssign( -- 247
			{}, -- 248
			m, -- 248
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 248
		) or __TS__ObjectAssign( -- 248
			{}, -- 249
			m, -- 249
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 249
		) end -- 249
	) -- 249
	local total = #normalized -- 250
	local failed = 0 -- 251
	do -- 251
		local i = 0 -- 252
		while i < #normalized do -- 252
			if not normalized[i + 1].success then -- 252
				failed = failed + 1 -- 253
			end -- 253
			i = i + 1 -- 252
		end -- 252
	end -- 252
	local passed = total - failed -- 255
	if failed > 0 then -- 255
		local interrupted = __TS__ArraySome( -- 257
			normalized, -- 257
			function(____, message) return not message.success and message.interrupted == true end -- 257
		) -- 257
		return { -- 258
			success = false, -- 259
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 260
			total = total, -- 261
			passed = passed, -- 262
			failed = failed, -- 263
			messages = normalized, -- 264
			interrupted = interrupted or nil -- 265
		} -- 265
	end -- 265
	return { -- 268
		success = true, -- 269
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 270
		total = total, -- 271
		passed = passed, -- 272
		failed = 0, -- 273
		messages = normalized -- 274
	} -- 274
end -- 246
function ____exports.build(req) -- 278
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 278
		local ____this_18 -- 278
		____this_18 = req -- 279
		local ____opt_17 = ____this_18.isCancelled -- 279
		if (____opt_17 and ____opt_17(____this_18)) == true then -- 279
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 279
		end -- 279
		local targetRel = req.path or "" -- 282
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 283
		if not target then -- 283
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 283
		end -- 283
		if not Content:exist(target) then -- 283
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 283
		end -- 283
		local messages = {} -- 290
		if not Content:isdir(target) then -- 290
			local kind = getSupportedBuildKind(target) -- 292
			if not kind then -- 292
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 292
			end -- 292
			if kind == "ts" then -- 292
				local content = Content:load(target) -- 297
				if content == nil then -- 297
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 297
				end -- 297
				if isTiledEditorContent(content) then -- 297
					Log("Info", "[build] skip tiled editor file=" .. target) -- 302
					return ____awaiter_resolve( -- 302
						nil, -- 302
						finalizeBuildResult(req.workDir, messages) -- 303
					) -- 303
				end -- 303
				if not sendWebIDEFileUpdate(target, true, content) then -- 303
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 303
				end -- 303
				if not isDtsFile(target) then -- 303
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 309
				end -- 309
			else -- 309
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target, req.workDir, req.isCancelled)) -- 312
			end -- 312
			Log( -- 314
				"Info", -- 314
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 314
			) -- 314
			return ____awaiter_resolve( -- 314
				nil, -- 314
				finalizeBuildResult(req.workDir, messages) -- 315
			) -- 315
		end -- 315
		local listResult = listFiles({ -- 317
			workDir = req.workDir, -- 318
			path = targetRel, -- 319
			globs = __TS__ArrayMap( -- 320
				codeExtensions, -- 320
				function(____, e) return "**/*" .. e end -- 320
			), -- 320
			maxEntries = 10000 -- 321
		}) -- 321
		local relFiles = listResult.success and listResult.files or ({}) -- 324
		local tsFileData = {} -- 325
		local buildQueue = {} -- 326
		for ____, rel in ipairs(relFiles) do -- 327
			do -- 327
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 328
				local kind = getSupportedBuildKind(file) -- 329
				if not kind then -- 329
					goto __continue79 -- 330
				end -- 330
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 331
				if kind ~= "ts" then -- 331
					goto __continue79 -- 333
				end -- 333
				local content = Content:load(file) -- 335
				if content == nil then -- 335
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 337
					goto __continue79 -- 338
				end -- 338
				if isTiledEditorContent(content) then -- 338
					Log("Info", "[build] skip tiled editor file=" .. file) -- 341
					goto __continue79 -- 342
				end -- 342
				tsFileData[file] = content -- 344
			end -- 344
			::__continue79:: -- 344
		end -- 344
		do -- 344
			local i = 0 -- 346
			while i < #buildQueue do -- 346
				do -- 346
					local ____this_20 -- 346
					____this_20 = req -- 347
					local ____opt_19 = ____this_20.isCancelled -- 347
					if (____opt_19 and ____opt_19(____this_20)) == true then -- 347
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 347
					end -- 347
					local ____buildQueue_index_21 = buildQueue[i + 1] -- 350
					local file = ____buildQueue_index_21.file -- 350
					local kind = ____buildQueue_index_21.kind -- 350
					if kind == "ts" then -- 350
						local content = tsFileData[file] -- 352
						if content == nil or isDtsFile(file) then -- 352
							goto __continue86 -- 354
						end -- 354
						if not sendWebIDEFileUpdate(file, true, content) then -- 354
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 357
							goto __continue86 -- 358
						end -- 358
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 360
						goto __continue86 -- 361
					end -- 361
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file, req.workDir, req.isCancelled)) -- 363
				end -- 363
				::__continue86:: -- 363
				i = i + 1 -- 346
			end -- 346
		end -- 346
		if #messages == 0 then -- 346
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 366
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 366
		end -- 366
		Log( -- 369
			"Info", -- 369
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 369
		) -- 369
		return ____awaiter_resolve( -- 369
			nil, -- 369
			finalizeBuildResult(req.workDir, messages) -- 370
		) -- 370
	end) -- 370
end -- 278
return ____exports -- 278