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
local AgentConfig = require("Agent.Config") -- 3
local ____Questionnaire = require("Agent.Questionnaire") -- 4
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
	local ____end = parseReadLine(input.endLine, start.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit, "endLine") -- 74
	if ____end.success == false then -- 74
		return {success = false, message = ____end.message .. suffix} -- 75
	end -- 75
	return {success = true, value = {path = path, startLine = start.value, endLine = ____end.value}} -- 76
end -- 64
local function getFinishMessage(input) -- 79
	local candidates = {input.message, input.response, input.summary} -- 80
	do -- 80
		local i = 0 -- 81
		while i < #candidates do -- 81
			if type(candidates[i + 1]) == "string" and __TS__StringTrim(candidates[i + 1]) ~= "" then -- 81
				return __TS__StringTrim(candidates[i + 1]) -- 83
			end -- 83
			i = i + 1 -- 81
		end -- 81
	end -- 81
	return "" -- 86
end -- 79
function ____exports.validateAgentToolInput(tool, input) -- 89
	local value = __TS__ObjectAssign({}, input) -- 90
	if tool == "finish" then -- 90
		local message = getFinishMessage(value) -- 92
		if message == "" then -- 92
			return {success = false, message = "finish requires params.message"} -- 93
		end -- 93
		local completion = AgentUtils.normalizeAgentCompletionReport(value) -- 94
		value.message = message -- 95
		value.outcome = completion.outcome -- 96
		value.validation = completion.validation -- 97
		value.knownIssues = completion.knownIssues -- 98
		value.assumptions = completion.assumptions -- 99
		value.learningCandidates = completion.learningCandidates -- 100
		return {success = true, value = value} -- 101
	end -- 101
	if tool == "ask_user" then -- 101
		local normalized = normalizeQuestionnaire(value) -- 104
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 105
	end -- 105
	if tool == "read_file" then -- 105
		local hasReads = value.reads ~= nil -- 110
		local hasPath = value.path ~= nil -- 111
		if not hasReads and not hasPath then -- 111
			return {success = false, message = "read_file requires path or reads"} -- 113
		end -- 113
		if not hasPath and (value.startLine ~= nil or value.endLine ~= nil) then -- 113
			return {success = false, message = "read_file startLine/endLine require a top-level path"} -- 116
		end -- 116
		local reads = {} -- 118
		if hasPath then -- 118
			local normalized = normalizeReadRange(value) -- 120
			if normalized.success == false then -- 120
				return normalized -- 121
			end -- 121
			reads[#reads + 1] = normalized.value -- 122
		end -- 122
		if hasReads then -- 122
			if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 122
				return {success = false, message = "read_file reads must be a non-empty array"} -- 126
			end -- 126
			do -- 126
				local i = 0 -- 128
				while i < #value.reads do -- 128
					local normalized = normalizeReadRange(value.reads[i + 1], i) -- 129
					if normalized.success == false then -- 129
						return normalized -- 130
					end -- 130
					reads[#reads + 1] = normalized.value -- 131
					i = i + 1 -- 128
				end -- 128
			end -- 128
		end -- 128
		if not hasReads then -- 128
			value.path = reads[1].path -- 135
			value.startLine = reads[1].startLine -- 136
			value.endLine = reads[1].endLine -- 137
			return {success = true, value = value} -- 138
		end -- 138
		value.path = nil -- 140
		value.startLine = nil -- 141
		value.endLine = nil -- 142
		value.reads = reads -- 143
		return {success = true, value = value} -- 144
	end -- 144
	if tool == "edit_file" then -- 144
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 147
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 148
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 148
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 150
		end -- 150
		local edits = ____exports.getAgentFileEditInputs(value) -- 152
		if #edits < 1 then -- 152
			return {success = false, message = "edit_file edits must not be empty"} -- 154
		end -- 154
		if not hasBatch then -- 154
			if edits[1].path == "" then -- 154
				return {success = false, message = "edit_file requires path"} -- 157
			end -- 157
			if edits[1].oldStr == edits[1].newStr then -- 157
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 158
			end -- 158
		end -- 158
		if hasBatch then -- 158
			value.edits = __TS__ArrayMap( -- 161
				edits, -- 161
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 161
			) -- 161
		else -- 161
			value.path = edits[1].path -- 163
			value.old_str = edits[1].oldStr -- 164
			value.new_str = edits[1].newStr -- 165
		end -- 165
		return {success = true, value = value} -- 167
	end -- 167
	if tool == "delete_file" then -- 167
		local target = getDecisionPath(value) -- 170
		if target == "" then -- 170
			return {success = false, message = "delete_file requires target_file"} -- 171
		end -- 171
		value.target_file = target -- 172
		return {success = true, value = value} -- 173
	end -- 173
	if tool == "grep_files" or tool == "search_dora_doc" then -- 173
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 176
		if pattern == "" then -- 176
			return {success = false, message = tool .. " requires pattern"} -- 177
		end -- 177
		value.pattern = pattern -- 178
		if tool == "grep_files" then -- 178
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 180
			value.offset = clampInteger(value.offset, 0, 0) -- 181
		else -- 181
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 183
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 183
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 185
			end -- 185
			value.docType = docType -- 187
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 188
		end -- 188
		return {success = true, value = value} -- 190
	end -- 190
	if tool == "glob_files" then -- 190
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 193
		return {success = true, value = value} -- 194
	end -- 194
	if tool == "build" then -- 194
		local hasPaths = value.paths ~= nil -- 197
		local hasPath = value.path ~= nil -- 198
		if not hasPaths and not hasPath then -- 198
			return {success = false, message = "build requires paths or path"} -- 199
		end -- 199
		local paths = {} -- 200
		if hasPath then -- 200
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 202
			if path == "" then -- 202
				return {success = false, message = "build path must be non-empty"} -- 203
			end -- 203
			paths[#paths + 1] = path -- 204
		end -- 204
		if hasPaths then -- 204
			if not __TS__ArrayIsArray(value.paths) then -- 204
				return {success = false, message = "build paths must be a non-empty array"} -- 207
			end -- 207
			local arrayPaths = __TS__ArrayMap( -- 208
				value.paths, -- 208
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 208
			) -- 208
			if #arrayPaths < 1 or __TS__ArraySome( -- 208
				arrayPaths, -- 209
				function(____, path) return path == "" end -- 209
			) then -- 209
				return {success = false, message = "build paths must contain non-empty paths"} -- 210
			end -- 210
			do -- 210
				local i = 0 -- 212
				while i < #arrayPaths do -- 212
					paths[#paths + 1] = arrayPaths[i + 1] -- 212
					i = i + 1 -- 212
				end -- 212
			end -- 212
		end -- 212
		value.path = nil -- 214
		value.paths = paths -- 215
		return {success = true, value = value} -- 216
	end -- 216
	if tool == "fetch_url" then -- 216
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 219
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 220
		if url == "" then -- 220
			return {success = false, message = "fetch_url requires url"} -- 221
		end -- 221
		if target == "" then -- 221
			return {success = false, message = "fetch_url requires target"} -- 222
		end -- 222
		value.url = url -- 223
		value.target = target -- 224
		return {success = true, value = value} -- 225
	end -- 225
	if tool == "analyze_image" then -- 225
		local function imageExt(path) -- 228
			local ext = string.lower(Path:getExt(path)) -- 229
			return ext == "png" or ext == "jpg" or ext == "jpeg" -- 230
		end -- 228
		if not __TS__ArrayIsArray(value.paths) or #value.paths < 1 or #value.paths > 3 or __TS__ArraySome( -- 228
			value.paths, -- 232
			function(____, item) return type(item) ~= "string" or __TS__StringTrim(item) == "" or not isValidWorkspacePath(__TS__StringTrim(item)) or not imageExt(__TS__StringTrim(item)) end -- 232
		) then -- 232
			return {success = false, message = "analyze_image requires 1–3 project-relative PNG/JPEG image paths"} -- 233
		end -- 233
		value.paths = __TS__ArrayMap( -- 235
			value.paths, -- 235
			function(____, item) return __TS__StringTrim(item) end -- 235
		) -- 235
		for ____, name in ipairs({"question", "criteria", "context"}) do -- 236
			do -- 236
				local text = value[name] -- 237
				if (name == "criteria" or name == "context") and text == nil then -- 237
					goto __continue76 -- 238
				end -- 238
				if type(text) ~= "string" or name == "question" and __TS__StringTrim(text) == "" then -- 238
					return {success = false, message = name .. " must be valid text"} -- 239
				end -- 239
				local length = utf8.len(text) -- 240
				if length == nil or length > 4000 then -- 240
					return {success = false, message = name .. " must contain at most 4000 Unicode characters"} -- 241
				end -- 241
			end -- 241
			::__continue76:: -- 241
		end -- 241
		return {success = true, value = value} -- 243
	end -- 243
	if tool == "execute_command" then -- 243
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 246
		if mode ~= "lua" and mode ~= "git" then -- 246
			return {success = false, message = "execute_command requires mode: lua or git"} -- 247
		end -- 247
		value.mode = mode -- 248
		if mode == "lua" then -- 248
			local code = type(value.code) == "string" and value.code or "" -- 250
			if __TS__StringTrim(code) == "" then -- 250
				return {success = false, message = "execute_command lua mode requires code"} -- 251
			end -- 251
			value.code = code -- 252
		else -- 252
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 254
			if command == "" then -- 254
				return {success = false, message = "execute_command git mode requires command"} -- 255
			end -- 255
			value.command = command -- 256
			if type(value.cwd) == "string" then -- 256
				value.cwd = __TS__StringTrim(value.cwd) -- 257
			end -- 257
		end -- 257
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 120 or 1800) -- 259
		return {success = true, value = value} -- 260
	end -- 260
	if tool == "list_sub_agents" then -- 260
		if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 260
			value.status = __TS__StringTrim(value.status) -- 263
		end -- 263
		value.limit = clampInteger(value.limit, 5, 1) -- 264
		value.offset = clampInteger(value.offset, 0, 0) -- 265
		if type(value.query) == "string" then -- 265
			value.query = __TS__StringTrim(value.query) -- 266
		end -- 266
		return {success = true, value = value} -- 267
	end -- 267
	if tool == "spawn_sub_agent" then -- 267
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 270
		local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 271
		if prompt == "" then -- 271
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 272
		end -- 272
		if title == "" then -- 272
			return {success = false, message = "spawn_sub_agent requires title"} -- 273
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
		return {success = true, value = value} -- 280
	end -- 280
	return {success = true, value = value} -- 282
end -- 89
____exports.AGENT_TOOL_VALIDATORS = { -- 285
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 286
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 287
	delete_file = function(value) return ____exports.validateAgentToolInput("delete_file", value) end, -- 288
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 289
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 290
	glob_files = function(value) return ____exports.validateAgentToolInput("glob_files", value) end, -- 291
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 292
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 293
	analyze_image = function(value) return ____exports.validateAgentToolInput("analyze_image", value) end, -- 294
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 295
	list_sub_agents = function(value) return ____exports.validateAgentToolInput("list_sub_agents", value) end, -- 296
	spawn_sub_agent = function(value) return ____exports.validateAgentToolInput("spawn_sub_agent", value) end, -- 297
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 298
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 299
} -- 299
return ____exports -- 299