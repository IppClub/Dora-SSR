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
local function runSingleNonTsBuild(file) -- 66
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 66
		return ____awaiter_resolve( -- 66
			nil, -- 66
			__TS__New( -- 67
				__TS__Promise, -- 67
				function(____, resolve) -- 67
					local moduleName = "Script.Dev.WebServer" -- 68
					local ____require_result_0 = require(moduleName) -- 69
					local buildAsync = ____require_result_0.buildAsync -- 69
					Director.systemScheduler:schedule(once(function() -- 70
						local result = buildAsync(file) -- 71
						resolve(nil, result) -- 72
					end)) -- 70
				end -- 67
			) -- 67
		) -- 67
	end) -- 67
end -- 66
local transpileRequestSeq = 0 -- 77
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 78
local TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 79
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 81
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 81
		local done = false -- 87
		local ready = false -- 88
		transpileRequestSeq = transpileRequestSeq + 1 -- 89
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 90
		local result = {success = false, file = file, message = "Web IDE not connected"} -- 91
		if HttpServer.wsConnectionCount == 0 then -- 91
			return ____awaiter_resolve(nil, result) -- 91
		end -- 91
		local listener = Node() -- 99
		listener:gslot( -- 100
			"AppWS", -- 100
			function(event) -- 100
				if event.type ~= "Receive" then -- 100
					return -- 101
				end -- 101
				local res = safeJsonDecode(event.msg) -- 102
				if not res or __TS__ArrayIsArray(res) then -- 102
					return -- 103
				end -- 103
				local payload = res -- 104
				if payload.id ~= requestId then -- 104
					return -- 105
				end -- 105
				if payload.name == "TranspileTSProbe" then -- 105
					ready = true -- 107
					return -- 108
				end -- 108
				if payload.name ~= "TranspileTS" then -- 108
					return -- 110
				end -- 110
				if payload.success then -- 110
					local luaFile = Path:replaceExt(file, "lua") -- 112
					if Content:save( -- 112
						luaFile, -- 113
						tostring(payload.luaCode) -- 113
					) then -- 113
						result = {success = true, file = file} -- 114
					else -- 114
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 116
					end -- 116
				else -- 116
					result = { -- 119
						success = false, -- 119
						file = file, -- 119
						message = tostring(payload.message) -- 119
					} -- 119
				end -- 119
				done = true -- 121
			end -- 100
		) -- 100
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 123
		local buildPayload = encodeJSON({ -- 124
			name = "TranspileTS", -- 125
			id = requestId, -- 126
			file = file, -- 127
			content = content, -- 128
			projectRoot = projectRoot -- 129
		}) -- 129
		if not probePayload or not buildPayload then -- 129
			listener:removeFromParent() -- 132
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 132
		end -- 132
		__TS__Await(__TS__New( -- 135
			__TS__Promise, -- 135
			function(____, resolve) -- 135
				Director.systemScheduler:schedule(once(function() -- 136
					emit("AppWS", "Send", probePayload) -- 137
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 138
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 139
					if not ready then -- 139
						listener:removeFromParent() -- 144
						if (isCancelled and isCancelled()) == true then -- 144
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 146
						elseif HttpServer.wsConnectionCount == 0 then -- 146
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 148
						else -- 148
							result = {success = false, file = file, message = "TypeScript transpiler is not ready"} -- 150
						end -- 150
						resolve(nil) -- 152
						return -- 153
					end -- 153
					emit("AppWS", "Send", buildPayload) -- 155
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 156
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 157
					if not done then -- 157
						listener:removeFromParent() -- 162
						if (isCancelled and isCancelled()) == true then -- 162
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 164
						elseif HttpServer.wsConnectionCount == 0 then -- 164
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 166
						else -- 166
							result = {success = false, file = file, message = "TypeScript transpile timed out"} -- 168
						end -- 168
					end -- 168
					resolve(nil) -- 171
				end)) -- 136
			end -- 135
		)) -- 135
		return ____awaiter_resolve(nil, result) -- 135
	end) -- 135
end -- 81
local function finalizeBuildResult(workDir, messages) -- 177
	local normalized = __TS__ArrayMap( -- 178
		messages, -- 178
		function(____, m) return m.success and __TS__ObjectAssign( -- 178
			{}, -- 179
			m, -- 179
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 179
		) or __TS__ObjectAssign( -- 179
			{}, -- 180
			m, -- 180
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 180
		) end -- 180
	) -- 180
	local total = #normalized -- 181
	local failed = 0 -- 182
	do -- 182
		local i = 0 -- 183
		while i < #normalized do -- 183
			if not normalized[i + 1].success then -- 183
				failed = failed + 1 -- 184
			end -- 184
			i = i + 1 -- 183
		end -- 183
	end -- 183
	local passed = total - failed -- 186
	if failed > 0 then -- 186
		local interrupted = __TS__ArraySome( -- 188
			normalized, -- 188
			function(____, message) return not message.success and message.interrupted == true end -- 188
		) -- 188
		return { -- 189
			success = false, -- 190
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 191
			total = total, -- 192
			passed = passed, -- 193
			failed = failed, -- 194
			messages = normalized, -- 195
			interrupted = interrupted or nil -- 196
		} -- 196
	end -- 196
	return { -- 199
		success = true, -- 200
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 201
		total = total, -- 202
		passed = passed, -- 203
		failed = 0, -- 204
		messages = normalized -- 205
	} -- 205
end -- 177
function ____exports.build(req) -- 209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 209
		local ____this_10 -- 209
		____this_10 = req -- 210
		local ____opt_9 = ____this_10.isCancelled -- 210
		if (____opt_9 and ____opt_9(____this_10)) == true then -- 210
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 210
		end -- 210
		local targetRel = req.path or "" -- 213
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 214
		if not target then -- 214
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 214
		end -- 214
		if not Content:exist(target) then -- 214
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 214
		end -- 214
		local messages = {} -- 221
		if not Content:isdir(target) then -- 221
			local kind = getSupportedBuildKind(target) -- 223
			if not kind then -- 223
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 223
			end -- 223
			if kind == "ts" then -- 223
				local content = Content:load(target) -- 228
				if content == nil then -- 228
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 228
				end -- 228
				if isTiledEditorContent(content) then -- 228
					Log("Info", "[build] skip tiled editor file=" .. target) -- 233
					return ____awaiter_resolve( -- 233
						nil, -- 233
						finalizeBuildResult(req.workDir, messages) -- 234
					) -- 234
				end -- 234
				if not sendWebIDEFileUpdate(target, true, content) then -- 234
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 234
				end -- 234
				if not isDtsFile(target) then -- 234
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 240
				end -- 240
			else -- 240
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 243
			end -- 243
			Log( -- 245
				"Info", -- 245
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 245
			) -- 245
			return ____awaiter_resolve( -- 245
				nil, -- 245
				finalizeBuildResult(req.workDir, messages) -- 246
			) -- 246
		end -- 246
		local listResult = listFiles({ -- 248
			workDir = req.workDir, -- 249
			path = targetRel, -- 250
			globs = __TS__ArrayMap( -- 251
				codeExtensions, -- 251
				function(____, e) return "**/*" .. e end -- 251
			), -- 251
			maxEntries = 10000 -- 252
		}) -- 252
		local relFiles = listResult.success and listResult.files or ({}) -- 255
		local tsFileData = {} -- 256
		local buildQueue = {} -- 257
		for ____, rel in ipairs(relFiles) do -- 258
			do -- 258
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 259
				local kind = getSupportedBuildKind(file) -- 260
				if not kind then -- 260
					goto __continue55 -- 261
				end -- 261
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 262
				if kind ~= "ts" then -- 262
					goto __continue55 -- 264
				end -- 264
				local content = Content:load(file) -- 266
				if content == nil then -- 266
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 268
					goto __continue55 -- 269
				end -- 269
				if isTiledEditorContent(content) then -- 269
					Log("Info", "[build] skip tiled editor file=" .. file) -- 272
					goto __continue55 -- 273
				end -- 273
				tsFileData[file] = content -- 275
			end -- 275
			::__continue55:: -- 275
		end -- 275
		do -- 275
			local i = 0 -- 277
			while i < #buildQueue do -- 277
				do -- 277
					local ____this_12 -- 277
					____this_12 = req -- 278
					local ____opt_11 = ____this_12.isCancelled -- 278
					if (____opt_11 and ____opt_11(____this_12)) == true then -- 278
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 278
					end -- 278
					local ____buildQueue_index_13 = buildQueue[i + 1] -- 281
					local file = ____buildQueue_index_13.file -- 281
					local kind = ____buildQueue_index_13.kind -- 281
					if kind == "ts" then -- 281
						local content = tsFileData[file] -- 283
						if content == nil or isDtsFile(file) then -- 283
							goto __continue62 -- 285
						end -- 285
						if not sendWebIDEFileUpdate(file, true, content) then -- 285
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 288
							goto __continue62 -- 289
						end -- 289
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 291
						goto __continue62 -- 292
					end -- 292
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 294
				end -- 294
				::__continue62:: -- 294
				i = i + 1 -- 277
			end -- 277
		end -- 277
		if #messages == 0 then -- 277
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 297
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 297
		end -- 297
		Log( -- 300
			"Info", -- 300
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 300
		) -- 300
		return ____awaiter_resolve( -- 300
			nil, -- 300
			finalizeBuildResult(req.workDir, messages) -- 301
		) -- 301
	end) -- 301
end -- 209
return ____exports -- 209