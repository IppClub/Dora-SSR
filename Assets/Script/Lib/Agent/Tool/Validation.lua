-- [ts]: Validation.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Path = ____Dora.Path -- 2
local AgentConfig = require("Agent.Config.Defaults") -- 3
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 4
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 4
local AgentUtils = require("Agent.Utils") -- 5
local ____Workspace = require("Agent.Tool.Workspace") -- 7
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 7
local function getDecisionPath(input) -- 9
	if type(input.path) == "string" then -- 9
		return __TS__StringTrim(input.path) -- 10
	end -- 10
	if type(input.target_file) == "string" then -- 10
		return __TS__StringTrim(input.target_file) -- 11
	end -- 11
	return "" -- 12
end -- 9
function ____exports.getAgentFileEditInputs(input) -- 22
	if __TS__ArrayIsArray(input.edits) then -- 22
		local commonPath = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 24
		local edits = {} -- 25
		do -- 25
			local i = 0 -- 26
			while i < #input.edits do -- 26
				local item = input.edits[i + 1] -- 27
				edits[#edits + 1] = { -- 28
					index = i, -- 29
					path = type(item.path) == "string" and __TS__StringTrim(item.path) ~= "" and __TS__StringTrim(item.path) or commonPath, -- 30
					oldStr = type(item.old_str) == "string" and item.old_str or "", -- 31
					newStr = type(item.new_str) == "string" and item.new_str or "" -- 32
				} -- 32
				i = i + 1 -- 26
			end -- 26
		end -- 26
		return edits -- 35
	end -- 35
	return {{ -- 37
		index = 0, -- 38
		path = type(input.path) == "string" and __TS__StringTrim(input.path) or "", -- 39
		oldStr = type(input.old_str) == "string" and input.old_str or "", -- 40
		newStr = type(input.new_str) == "string" and input.new_str or "" -- 41
	}} -- 41
end -- 22
local function clampInteger(value, fallback, minValue, maxValue) -- 45
	local num = __TS__Number(value) -- 46
	if not __TS__NumberIsFinite(num) then -- 46
		num = fallback -- 47
	end -- 47
	num = math.floor(num) -- 48
	if num < minValue then -- 48
		num = minValue -- 49
	end -- 49
	if maxValue ~= nil and num > maxValue then -- 49
		num = maxValue -- 50
	end -- 50
	return num -- 51
end -- 45
local function parseReadLine(value, fallback, name) -- 54
	local num = __TS__Number(value) -- 57
	if not __TS__NumberIsFinite(num) then -- 57
		num = fallback -- 58
	end -- 58
	num = math.floor(num) -- 59
	if num == 0 then -- 59
		return {success = false, message = name .. " cannot be 0"} -- 60
	end -- 60
	return {success = true, value = num} -- 61
end -- 54
local function normalizeReadRange(value, index) -- 64
	local suffix = index == nil and "" or " at index " .. tostring(index) -- 65
	if type(value) ~= "table" or value == nil or __TS__ArrayIsArray(value) then -- 65
		return {success = false, message = "read_file requires an object" .. suffix} -- 67
	end -- 67
	local input = value -- 69
	local path = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 70
	if path == "" then -- 70
		return {success = false, message = "read_file requires path" .. suffix} -- 71
	end -- 71
	local start = parseReadLine(input.startLine, 1, "startLine") -- 72
	if start.success == false then -- 72
		return {success = false, message = start.message .. suffix} -- 73
	end -- 73
	local ____temp_0 -- 75
	if input.endLine == nil then -- 75
		____temp_0 = nil -- 75
	else -- 75
		____temp_0 = parseReadLine(input.endLine, start.value < 0 and -1 or start.value + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1, "endLine") -- 75
	end -- 75
	local ____end = ____temp_0 -- 75
	if (____end and ____end.success) == false then -- 75
		return {success = false, message = ____end.message .. suffix} -- 77
	end -- 77
	return {success = true, value = {path = path, startLine = start.value, endLine = ____end and ____end.value}} -- 78
end -- 64
local function getFinishMessage(input) -- 81
	local candidates = {input.message, input.response, input.summary} -- 82
	do -- 82
		local i = 0 -- 83
		while i < #candidates do -- 83
			if type(candidates[i + 1]) == "string" and __TS__StringTrim(candidates[i + 1]) ~= "" then -- 83
				return __TS__StringTrim(candidates[i + 1]) -- 85
			end -- 85
			i = i + 1 -- 83
		end -- 83
	end -- 83
	return "" -- 88
end -- 81
function ____exports.validateAgentToolInput(tool, input) -- 91
	local value = __TS__ObjectAssign({}, input) -- 92
	if tool == "finish" then -- 92
		local message = getFinishMessage(value) -- 94
		if message == "" then -- 94
			return {success = false, message = "finish requires params.message"} -- 95
		end -- 95
		local completion = AgentUtils.normalizeAgentCompletionReport(value) -- 96
		value.message = message -- 97
		value.outcome = completion.outcome -- 98
		value.validation = completion.validation -- 99
		value.knownIssues = completion.knownIssues -- 100
		value.assumptions = completion.assumptions -- 101
		value.learningCandidates = completion.learningCandidates -- 102
		return {success = true, value = value} -- 103
	end -- 103
	if tool == "ask_user" then -- 103
		local normalized = normalizeQuestionnaire(value) -- 106
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 107
	end -- 107
	if tool == "read_file" then -- 107
		local hasReads = value.reads ~= nil -- 112
		local hasPath = value.path ~= nil -- 113
		if not hasReads and not hasPath then -- 113
			return {success = false, message = "read_file requires path or reads"} -- 115
		end -- 115
		if not hasPath and (value.startLine ~= nil or value.endLine ~= nil) then -- 115
			return {success = false, message = "read_file startLine/endLine require a top-level path"} -- 118
		end -- 118
		local reads = {} -- 120
		if hasPath then -- 120
			local normalized = normalizeReadRange(value) -- 122
			if normalized.success == false then -- 122
				return normalized -- 123
			end -- 123
			reads[#reads + 1] = normalized.value -- 124
		end -- 124
		if hasReads then -- 124
			if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 124
				return {success = false, message = "read_file reads must be a non-empty array"} -- 128
			end -- 128
			do -- 128
				local i = 0 -- 130
				while i < #value.reads do -- 130
					local normalized = normalizeReadRange(value.reads[i + 1], i) -- 131
					if normalized.success == false then -- 131
						return normalized -- 132
					end -- 132
					reads[#reads + 1] = normalized.value -- 133
					i = i + 1 -- 130
				end -- 130
			end -- 130
		end -- 130
		if not hasReads then -- 130
			value.path = reads[1].path -- 137
			value.startLine = reads[1].startLine -- 138
			value.endLine = reads[1].endLine -- 139
			return {success = true, value = value} -- 140
		end -- 140
		value.path = nil -- 142
		value.startLine = nil -- 143
		value.endLine = nil -- 144
		value.reads = reads -- 145
		return {success = true, value = value} -- 146
	end -- 146
	if tool == "edit_file" then -- 146
		if value.delete == true then -- 146
			if __TS__ArrayIsArray(value.edits) then -- 146
				return {success = false, message = "edit_file delete cannot be combined with edits; call delete separately"} -- 151
			end -- 151
			if value.old_str ~= nil or value.new_str ~= nil then -- 151
				return {success = false, message = "edit_file delete cannot be combined with old_str/new_str"} -- 152
			end -- 152
			local target = getDecisionPath(value) -- 153
			if target == "" then -- 153
				return {success = false, message = "edit_file delete requires path"} -- 154
			end -- 154
			value.path = target -- 155
			value.target_file = nil -- 156
			return {success = true, value = value} -- 157
		end -- 157
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 159
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 160
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 160
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 162
		end -- 162
		local edits = ____exports.getAgentFileEditInputs(value) -- 164
		if #edits < 1 then -- 164
			return {success = false, message = "edit_file edits must not be empty"} -- 166
		end -- 166
		if not hasBatch then -- 166
			if edits[1].path == "" then -- 166
				return {success = false, message = "edit_file requires path"} -- 169
			end -- 169
			if edits[1].oldStr == edits[1].newStr then -- 169
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 170
			end -- 170
		end -- 170
		if hasBatch then -- 170
			value.edits = __TS__ArrayMap( -- 173
				edits, -- 173
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 173
			) -- 173
		else -- 173
			value.path = edits[1].path -- 175
			value.old_str = edits[1].oldStr -- 176
			value.new_str = edits[1].newStr -- 177
		end -- 177
		return {success = true, value = value} -- 179
	end -- 179
	if tool == "grep_files" or tool == "search_dora_doc" then -- 179
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 182
		if pattern == "" and tool == "search_dora_doc" then -- 182
			return {success = false, message = tool .. " requires pattern"} -- 183
		end -- 183
		local ____temp_5 -- 184
		if pattern == "" then -- 184
			____temp_5 = nil -- 184
		else -- 184
			____temp_5 = pattern -- 184
		end -- 184
		value.pattern = ____temp_5 -- 184
		if tool == "grep_files" then -- 184
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 186
			value.offset = clampInteger(value.offset, 0, 0) -- 187
			value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 188
		else -- 188
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 190
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 190
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 192
			end -- 192
			value.docType = docType -- 194
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 195
		end -- 195
		return {success = true, value = value} -- 197
	end -- 197
	if tool == "build" then -- 197
		local hasPaths = value.paths ~= nil -- 200
		local hasPath = value.path ~= nil -- 201
		if not hasPaths and not hasPath then -- 201
			return {success = false, message = "build requires paths or path"} -- 202
		end -- 202
		local paths = {} -- 203
		if hasPath then -- 203
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 205
			if path == "" then -- 205
				return {success = false, message = "build path must be non-empty"} -- 206
			end -- 206
			paths[#paths + 1] = path -- 207
		end -- 207
		if hasPaths then -- 207
			if not __TS__ArrayIsArray(value.paths) then -- 207
				return {success = false, message = "build paths must be a non-empty array"} -- 210
			end -- 210
			local arrayPaths = __TS__ArrayMap( -- 211
				value.paths, -- 211
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 211
			) -- 211
			if #arrayPaths < 1 or __TS__ArraySome( -- 211
				arrayPaths, -- 212
				function(____, path) return path == "" end -- 212
			) then -- 212
				return {success = false, message = "build paths must contain non-empty paths"} -- 213
			end -- 213
			do -- 213
				local i = 0 -- 215
				while i < #arrayPaths do -- 215
					paths[#paths + 1] = arrayPaths[i + 1] -- 215
					i = i + 1 -- 215
				end -- 215
			end -- 215
		end -- 215
		value.path = nil -- 217
		value.paths = paths -- 218
		return {success = true, value = value} -- 219
	end -- 219
	if tool == "fetch_url" then -- 219
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 222
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 223
		if url == "" then -- 223
			return {success = false, message = "fetch_url requires url"} -- 224
		end -- 224
		if target == "" then -- 224
			return {success = false, message = "fetch_url requires target"} -- 225
		end -- 225
		value.url = url -- 226
		value.target = target -- 227
		return {success = true, value = value} -- 228
	end -- 228
	if tool == "analyze_image" then -- 228
		local function imageExt(path) -- 231
			local ext = string.lower(Path:getExt(path)) -- 232
			return ext == "png" or ext == "jpg" or ext == "jpeg" -- 233
		end -- 231
		if not __TS__ArrayIsArray(value.paths) or #value.paths < 1 or #value.paths > 3 or __TS__ArraySome( -- 231
			value.paths, -- 235
			function(____, item) return type(item) ~= "string" or __TS__StringTrim(item) == "" or not isValidWorkspacePath(__TS__StringTrim(item)) or not imageExt(__TS__StringTrim(item)) end -- 235
		) then -- 235
			return {success = false, message = "analyze_image requires 1–3 project-relative PNG/JPEG image paths"} -- 236
		end -- 236
		value.paths = __TS__ArrayMap( -- 238
			value.paths, -- 238
			function(____, item) return __TS__StringTrim(item) end -- 238
		) -- 238
		for ____, name in ipairs({"question", "criteria", "context"}) do -- 239
			do -- 239
				local text = value[name] -- 240
				if (name == "criteria" or name == "context") and text == nil then -- 240
					goto __continue77 -- 241
				end -- 241
				if type(text) ~= "string" or name == "question" and __TS__StringTrim(text) == "" then -- 241
					return {success = false, message = name .. " must be valid text"} -- 242
				end -- 242
				local length = utf8.len(text) -- 243
				if length == nil or length > 4000 then -- 243
					return {success = false, message = name .. " must contain at most 4000 Unicode characters"} -- 244
				end -- 244
			end -- 244
			::__continue77:: -- 244
		end -- 244
		return {success = true, value = value} -- 246
	end -- 246
	if tool == "execute_command" then -- 246
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 249
		if mode ~= "lua" and mode ~= "git" then -- 249
			return {success = false, message = "execute_command requires mode: lua or git"} -- 250
		end -- 250
		value.mode = mode -- 251
		if mode == "lua" then -- 251
			local code = type(value.code) == "string" and value.code or "" -- 253
			if __TS__StringTrim(code) == "" then -- 253
				return {success = false, message = "execute_command lua mode requires code"} -- 254
			end -- 254
			value.code = code -- 255
		else -- 255
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 257
			if command == "" then -- 257
				return {success = false, message = "execute_command git mode requires command"} -- 258
			end -- 258
			value.command = command -- 259
			if type(value.cwd) == "string" then -- 259
				value.cwd = __TS__StringTrim(value.cwd) -- 260
			end -- 260
		end -- 260
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 600 or 1800) -- 262
		return {success = true, value = value} -- 263
	end -- 263
	if tool == "spawn_agent" then -- 263
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 266
		if prompt ~= "" then -- 266
			if value.status ~= nil or value.limit ~= nil or value.offset ~= nil or value.query ~= nil then -- 266
				return {success = false, message = "spawn_agent spawn form cannot combine the list filters (status/limit/offset/query)"} -- 270
			end -- 270
			local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 272
			if title == "" then -- 272
				return {success = false, message = "spawn_agent spawn form requires title"} -- 273
			end -- 273
			value.prompt = prompt -- 274
			value.title = title -- 275
			if type(value.expectedOutput) == "string" then -- 275
				value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 276
			end -- 276
			if __TS__ArrayIsArray(value.filesHint) then -- 276
				value.filesHint = __TS__ArrayMap( -- 278
					__TS__ArrayFilter( -- 278
						value.filesHint, -- 278
						function(____, item) return type(item) == "string" end -- 278
					), -- 278
					function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 278
				) -- 278
			end -- 278
		else -- 278
			if value.title ~= nil or value.expectedOutput ~= nil or value.filesHint ~= nil then -- 278
				return {success = false, message = "spawn_agent list form cannot carry spawn fields (title/expectedOutput/filesHint)"} -- 283
			end -- 283
			value.prompt = nil -- 285
			value.title = nil -- 286
			if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 286
				value.status = __TS__StringTrim(value.status) -- 287
			end -- 287
			value.limit = clampInteger(value.limit, 5, 1) -- 288
			value.offset = clampInteger(value.offset, 0, 0) -- 289
			if type(value.query) == "string" then -- 289
				value.query = __TS__StringTrim(value.query) -- 290
			end -- 290
		end -- 290
		return {success = true, value = value} -- 292
	end -- 292
	return {success = true, value = value} -- 294
end -- 91
____exports.AGENT_TOOL_VALIDATORS = { -- 297
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 298
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 299
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 300
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 301
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 302
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 303
	analyze_image = function(value) return ____exports.validateAgentToolInput("analyze_image", value) end, -- 304
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 305
	spawn_agent = function(value) return ____exports.validateAgentToolInput("spawn_agent", value) end, -- 306
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 307
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 308
} -- 308
return ____exports -- 308