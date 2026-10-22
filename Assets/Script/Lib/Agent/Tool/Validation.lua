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
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 149
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 150
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 150
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 152
		end -- 152
		local edits = ____exports.getAgentFileEditInputs(value) -- 154
		if #edits < 1 then -- 154
			return {success = false, message = "edit_file edits must not be empty"} -- 156
		end -- 156
		if not hasBatch then -- 156
			if edits[1].path == "" then -- 156
				return {success = false, message = "edit_file requires path"} -- 159
			end -- 159
			if edits[1].oldStr == edits[1].newStr then -- 159
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 160
			end -- 160
		end -- 160
		if hasBatch then -- 160
			value.edits = __TS__ArrayMap( -- 163
				edits, -- 163
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 163
			) -- 163
		else -- 163
			value.path = edits[1].path -- 165
			value.old_str = edits[1].oldStr -- 166
			value.new_str = edits[1].newStr -- 167
		end -- 167
		return {success = true, value = value} -- 169
	end -- 169
	if tool == "delete_file" then -- 169
		local target = getDecisionPath(value) -- 172
		if target == "" then -- 172
			return {success = false, message = "delete_file requires target_file"} -- 173
		end -- 173
		value.target_file = target -- 174
		return {success = true, value = value} -- 175
	end -- 175
	if tool == "grep_files" or tool == "search_dora_doc" then -- 175
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 178
		if pattern == "" then -- 178
			return {success = false, message = tool .. " requires pattern"} -- 179
		end -- 179
		value.pattern = pattern -- 180
		if tool == "grep_files" then -- 180
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 182
			value.offset = clampInteger(value.offset, 0, 0) -- 183
		else -- 183
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 185
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 185
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 187
			end -- 187
			value.docType = docType -- 189
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 190
		end -- 190
		return {success = true, value = value} -- 192
	end -- 192
	if tool == "glob_files" then -- 192
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 195
		return {success = true, value = value} -- 196
	end -- 196
	if tool == "build" then -- 196
		local hasPaths = value.paths ~= nil -- 199
		local hasPath = value.path ~= nil -- 200
		if not hasPaths and not hasPath then -- 200
			return {success = false, message = "build requires paths or path"} -- 201
		end -- 201
		local paths = {} -- 202
		if hasPath then -- 202
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 204
			if path == "" then -- 204
				return {success = false, message = "build path must be non-empty"} -- 205
			end -- 205
			paths[#paths + 1] = path -- 206
		end -- 206
		if hasPaths then -- 206
			if not __TS__ArrayIsArray(value.paths) then -- 206
				return {success = false, message = "build paths must be a non-empty array"} -- 209
			end -- 209
			local arrayPaths = __TS__ArrayMap( -- 210
				value.paths, -- 210
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 210
			) -- 210
			if #arrayPaths < 1 or __TS__ArraySome( -- 210
				arrayPaths, -- 211
				function(____, path) return path == "" end -- 211
			) then -- 211
				return {success = false, message = "build paths must contain non-empty paths"} -- 212
			end -- 212
			do -- 212
				local i = 0 -- 214
				while i < #arrayPaths do -- 214
					paths[#paths + 1] = arrayPaths[i + 1] -- 214
					i = i + 1 -- 214
				end -- 214
			end -- 214
		end -- 214
		value.path = nil -- 216
		value.paths = paths -- 217
		return {success = true, value = value} -- 218
	end -- 218
	if tool == "fetch_url" then -- 218
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 221
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 222
		if url == "" then -- 222
			return {success = false, message = "fetch_url requires url"} -- 223
		end -- 223
		if target == "" then -- 223
			return {success = false, message = "fetch_url requires target"} -- 224
		end -- 224
		value.url = url -- 225
		value.target = target -- 226
		return {success = true, value = value} -- 227
	end -- 227
	if tool == "analyze_image" then -- 227
		local function imageExt(path) -- 230
			local ext = string.lower(Path:getExt(path)) -- 231
			return ext == "png" or ext == "jpg" or ext == "jpeg" -- 232
		end -- 230
		if not __TS__ArrayIsArray(value.paths) or #value.paths < 1 or #value.paths > 3 or __TS__ArraySome( -- 230
			value.paths, -- 234
			function(____, item) return type(item) ~= "string" or __TS__StringTrim(item) == "" or not isValidWorkspacePath(__TS__StringTrim(item)) or not imageExt(__TS__StringTrim(item)) end -- 234
		) then -- 234
			return {success = false, message = "analyze_image requires 1–3 project-relative PNG/JPEG image paths"} -- 235
		end -- 235
		value.paths = __TS__ArrayMap( -- 237
			value.paths, -- 237
			function(____, item) return __TS__StringTrim(item) end -- 237
		) -- 237
		for ____, name in ipairs({"question", "criteria", "context"}) do -- 238
			do -- 238
				local text = value[name] -- 239
				if (name == "criteria" or name == "context") and text == nil then -- 239
					goto __continue76 -- 240
				end -- 240
				if type(text) ~= "string" or name == "question" and __TS__StringTrim(text) == "" then -- 240
					return {success = false, message = name .. " must be valid text"} -- 241
				end -- 241
				local length = utf8.len(text) -- 242
				if length == nil or length > 4000 then -- 242
					return {success = false, message = name .. " must contain at most 4000 Unicode characters"} -- 243
				end -- 243
			end -- 243
			::__continue76:: -- 243
		end -- 243
		return {success = true, value = value} -- 245
	end -- 245
	if tool == "execute_command" then -- 245
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 248
		if mode ~= "lua" and mode ~= "git" then -- 248
			return {success = false, message = "execute_command requires mode: lua or git"} -- 249
		end -- 249
		value.mode = mode -- 250
		if mode == "lua" then -- 250
			local code = type(value.code) == "string" and value.code or "" -- 252
			if __TS__StringTrim(code) == "" then -- 252
				return {success = false, message = "execute_command lua mode requires code"} -- 253
			end -- 253
			value.code = code -- 254
		else -- 254
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 256
			if command == "" then -- 256
				return {success = false, message = "execute_command git mode requires command"} -- 257
			end -- 257
			value.command = command -- 258
			if type(value.cwd) == "string" then -- 258
				value.cwd = __TS__StringTrim(value.cwd) -- 259
			end -- 259
		end -- 259
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 600 or 1800) -- 261
		return {success = true, value = value} -- 262
	end -- 262
	if tool == "list_sub_agents" then -- 262
		if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 262
			value.status = __TS__StringTrim(value.status) -- 265
		end -- 265
		value.limit = clampInteger(value.limit, 5, 1) -- 266
		value.offset = clampInteger(value.offset, 0, 0) -- 267
		if type(value.query) == "string" then -- 267
			value.query = __TS__StringTrim(value.query) -- 268
		end -- 268
		return {success = true, value = value} -- 269
	end -- 269
	if tool == "spawn_sub_agent" then -- 269
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 272
		local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 273
		if prompt == "" then -- 273
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 274
		end -- 274
		if title == "" then -- 274
			return {success = false, message = "spawn_sub_agent requires title"} -- 275
		end -- 275
		value.prompt = prompt -- 276
		value.title = title -- 277
		if type(value.expectedOutput) == "string" then -- 277
			value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 278
		end -- 278
		if __TS__ArrayIsArray(value.filesHint) then -- 278
			value.filesHint = __TS__ArrayMap( -- 280
				__TS__ArrayFilter( -- 280
					value.filesHint, -- 280
					function(____, item) return type(item) == "string" end -- 280
				), -- 280
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 280
			) -- 280
		end -- 280
		return {success = true, value = value} -- 282
	end -- 282
	return {success = true, value = value} -- 284
end -- 91
____exports.AGENT_TOOL_VALIDATORS = { -- 287
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 288
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 289
	delete_file = function(value) return ____exports.validateAgentToolInput("delete_file", value) end, -- 290
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 291
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 292
	glob_files = function(value) return ____exports.validateAgentToolInput("glob_files", value) end, -- 293
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 294
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 295
	analyze_image = function(value) return ____exports.validateAgentToolInput("analyze_image", value) end, -- 296
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 297
	list_sub_agents = function(value) return ____exports.validateAgentToolInput("list_sub_agents", value) end, -- 298
	spawn_sub_agent = function(value) return ____exports.validateAgentToolInput("spawn_sub_agent", value) end, -- 299
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 300
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 301
} -- 301
return ____exports -- 301