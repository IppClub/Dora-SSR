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
local AgentConfig = require("Agent.Config") -- 2
local ____Questionnaire = require("Agent.Questionnaire") -- 3
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 3
local AgentUtils = require("Agent.Utils") -- 4
local function getDecisionPath(input) -- 7
	if type(input.path) == "string" then -- 7
		return __TS__StringTrim(input.path) -- 8
	end -- 8
	if type(input.target_file) == "string" then -- 8
		return __TS__StringTrim(input.target_file) -- 9
	end -- 9
	return "" -- 10
end -- 7
function ____exports.getAgentFileEditInputs(input) -- 20
	if __TS__ArrayIsArray(input.edits) then -- 20
		local commonPath = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 22
		local edits = {} -- 23
		do -- 23
			local i = 0 -- 24
			while i < #input.edits do -- 24
				local item = input.edits[i + 1] -- 25
				edits[#edits + 1] = { -- 26
					index = i, -- 27
					path = type(item.path) == "string" and __TS__StringTrim(item.path) ~= "" and __TS__StringTrim(item.path) or commonPath, -- 28
					oldStr = type(item.old_str) == "string" and item.old_str or "", -- 29
					newStr = type(item.new_str) == "string" and item.new_str or "" -- 30
				} -- 30
				i = i + 1 -- 24
			end -- 24
		end -- 24
		return edits -- 33
	end -- 33
	return {{ -- 35
		index = 0, -- 36
		path = type(input.path) == "string" and __TS__StringTrim(input.path) or "", -- 37
		oldStr = type(input.old_str) == "string" and input.old_str or "", -- 38
		newStr = type(input.new_str) == "string" and input.new_str or "" -- 39
	}} -- 39
end -- 20
local function clampInteger(value, fallback, minValue, maxValue) -- 43
	local num = __TS__Number(value) -- 44
	if not __TS__NumberIsFinite(num) then -- 44
		num = fallback -- 45
	end -- 45
	num = math.floor(num) -- 46
	if num < minValue then -- 46
		num = minValue -- 47
	end -- 47
	if maxValue ~= nil and num > maxValue then -- 47
		num = maxValue -- 48
	end -- 48
	return num -- 49
end -- 43
local function parseReadLine(value, fallback, name) -- 52
	local num = __TS__Number(value) -- 55
	if not __TS__NumberIsFinite(num) then -- 55
		num = fallback -- 56
	end -- 56
	num = math.floor(num) -- 57
	if num == 0 then -- 57
		return {success = false, message = name .. " cannot be 0"} -- 58
	end -- 58
	return {success = true, value = num} -- 59
end -- 52
local function normalizeReadRange(value, index) -- 62
	local suffix = index == nil and "" or " at index " .. tostring(index) -- 63
	if type(value) ~= "table" or value == nil or __TS__ArrayIsArray(value) then -- 63
		return {success = false, message = "read_file requires an object" .. suffix} -- 65
	end -- 65
	local input = value -- 67
	local path = type(input.path) == "string" and __TS__StringTrim(input.path) or "" -- 68
	if path == "" then -- 68
		return {success = false, message = "read_file requires path" .. suffix} -- 69
	end -- 69
	local start = parseReadLine(input.startLine, 1, "startLine") -- 70
	if start.success == false then -- 70
		return {success = false, message = start.message .. suffix} -- 71
	end -- 71
	local ____end = parseReadLine(input.endLine, start.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit, "endLine") -- 72
	if ____end.success == false then -- 72
		return {success = false, message = ____end.message .. suffix} -- 73
	end -- 73
	return {success = true, value = {path = path, startLine = start.value, endLine = ____end.value}} -- 74
end -- 62
local function getFinishMessage(input) -- 77
	local candidates = {input.message, input.response, input.summary} -- 78
	do -- 78
		local i = 0 -- 79
		while i < #candidates do -- 79
			if type(candidates[i + 1]) == "string" and __TS__StringTrim(candidates[i + 1]) ~= "" then -- 79
				return __TS__StringTrim(candidates[i + 1]) -- 81
			end -- 81
			i = i + 1 -- 79
		end -- 79
	end -- 79
	return "" -- 84
end -- 77
function ____exports.validateAgentToolInput(tool, input) -- 87
	local value = __TS__ObjectAssign({}, input) -- 88
	if tool == "finish" then -- 88
		local message = getFinishMessage(value) -- 90
		if message == "" then -- 90
			return {success = false, message = "finish requires params.message"} -- 91
		end -- 91
		local completion = AgentUtils.normalizeAgentCompletionReport(value) -- 92
		value.message = message -- 93
		value.outcome = completion.outcome -- 94
		value.validation = completion.validation -- 95
		value.knownIssues = completion.knownIssues -- 96
		value.assumptions = completion.assumptions -- 97
		value.learningCandidates = completion.learningCandidates -- 98
		return {success = true, value = value} -- 99
	end -- 99
	if tool == "ask_user" then -- 99
		local normalized = normalizeQuestionnaire(value) -- 102
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 103
	end -- 103
	if tool == "read_file" then -- 103
		local hasReads = value.reads ~= nil -- 108
		local hasPath = value.path ~= nil -- 109
		if not hasReads and not hasPath then -- 109
			return {success = false, message = "read_file requires path or reads"} -- 111
		end -- 111
		if not hasPath and (value.startLine ~= nil or value.endLine ~= nil) then -- 111
			return {success = false, message = "read_file startLine/endLine require a top-level path"} -- 114
		end -- 114
		local reads = {} -- 116
		if hasPath then -- 116
			local normalized = normalizeReadRange(value) -- 118
			if normalized.success == false then -- 118
				return normalized -- 119
			end -- 119
			reads[#reads + 1] = normalized.value -- 120
		end -- 120
		if hasReads then -- 120
			if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 120
				return {success = false, message = "read_file reads must be a non-empty array"} -- 124
			end -- 124
			do -- 124
				local i = 0 -- 126
				while i < #value.reads do -- 126
					local normalized = normalizeReadRange(value.reads[i + 1], i) -- 127
					if normalized.success == false then -- 127
						return normalized -- 128
					end -- 128
					reads[#reads + 1] = normalized.value -- 129
					i = i + 1 -- 126
				end -- 126
			end -- 126
		end -- 126
		if not hasReads then -- 126
			value.path = reads[1].path -- 133
			value.startLine = reads[1].startLine -- 134
			value.endLine = reads[1].endLine -- 135
			return {success = true, value = value} -- 136
		end -- 136
		value.path = nil -- 138
		value.startLine = nil -- 139
		value.endLine = nil -- 140
		value.reads = reads -- 141
		return {success = true, value = value} -- 142
	end -- 142
	if tool == "edit_file" then -- 142
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 145
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 146
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 146
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 148
		end -- 148
		local edits = ____exports.getAgentFileEditInputs(value) -- 150
		if #edits < 1 then -- 150
			return {success = false, message = "edit_file edits must not be empty"} -- 152
		end -- 152
		if not hasBatch then -- 152
			if edits[1].path == "" then -- 152
				return {success = false, message = "edit_file requires path"} -- 155
			end -- 155
			if edits[1].oldStr == edits[1].newStr then -- 155
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 156
			end -- 156
		end -- 156
		if hasBatch then -- 156
			value.edits = __TS__ArrayMap( -- 159
				edits, -- 159
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 159
			) -- 159
		else -- 159
			value.path = edits[1].path -- 161
			value.old_str = edits[1].oldStr -- 162
			value.new_str = edits[1].newStr -- 163
		end -- 163
		return {success = true, value = value} -- 165
	end -- 165
	if tool == "delete_file" then -- 165
		local target = getDecisionPath(value) -- 168
		if target == "" then -- 168
			return {success = false, message = "delete_file requires target_file"} -- 169
		end -- 169
		value.target_file = target -- 170
		return {success = true, value = value} -- 171
	end -- 171
	if tool == "grep_files" or tool == "search_dora_doc" then -- 171
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 174
		if pattern == "" then -- 174
			return {success = false, message = tool .. " requires pattern"} -- 175
		end -- 175
		value.pattern = pattern -- 176
		if tool == "grep_files" then -- 176
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 178
			value.offset = clampInteger(value.offset, 0, 0) -- 179
		else -- 179
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 181
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 181
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 183
			end -- 183
			value.docType = docType -- 185
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 186
		end -- 186
		return {success = true, value = value} -- 188
	end -- 188
	if tool == "glob_files" then -- 188
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 191
		return {success = true, value = value} -- 192
	end -- 192
	if tool == "build" then -- 192
		local hasPaths = value.paths ~= nil -- 195
		local hasPath = value.path ~= nil -- 196
		if not hasPaths and not hasPath then -- 196
			return {success = false, message = "build requires paths or path"} -- 197
		end -- 197
		local paths = {} -- 198
		if hasPath then -- 198
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 200
			if path == "" then -- 200
				return {success = false, message = "build path must be non-empty"} -- 201
			end -- 201
			paths[#paths + 1] = path -- 202
		end -- 202
		if hasPaths then -- 202
			if not __TS__ArrayIsArray(value.paths) then -- 202
				return {success = false, message = "build paths must be a non-empty array"} -- 205
			end -- 205
			local arrayPaths = __TS__ArrayMap( -- 206
				value.paths, -- 206
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 206
			) -- 206
			if #arrayPaths < 1 or __TS__ArraySome( -- 206
				arrayPaths, -- 207
				function(____, path) return path == "" end -- 207
			) then -- 207
				return {success = false, message = "build paths must contain non-empty paths"} -- 208
			end -- 208
			do -- 208
				local i = 0 -- 210
				while i < #arrayPaths do -- 210
					paths[#paths + 1] = arrayPaths[i + 1] -- 210
					i = i + 1 -- 210
				end -- 210
			end -- 210
		end -- 210
		value.path = nil -- 212
		value.paths = paths -- 213
		return {success = true, value = value} -- 214
	end -- 214
	if tool == "fetch_url" then -- 214
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 217
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 218
		if url == "" then -- 218
			return {success = false, message = "fetch_url requires url"} -- 219
		end -- 219
		if target == "" then -- 219
			return {success = false, message = "fetch_url requires target"} -- 220
		end -- 220
		value.url = url -- 221
		value.target = target -- 222
		return {success = true, value = value} -- 223
	end -- 223
	if tool == "execute_command" then -- 223
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 226
		if mode ~= "lua" and mode ~= "git" then -- 226
			return {success = false, message = "execute_command requires mode: lua or git"} -- 227
		end -- 227
		value.mode = mode -- 228
		if mode == "lua" then -- 228
			local code = type(value.code) == "string" and value.code or "" -- 230
			if __TS__StringTrim(code) == "" then -- 230
				return {success = false, message = "execute_command lua mode requires code"} -- 231
			end -- 231
			value.code = code -- 232
		else -- 232
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 234
			if command == "" then -- 234
				return {success = false, message = "execute_command git mode requires command"} -- 235
			end -- 235
			value.command = command -- 236
			if type(value.cwd) == "string" then -- 236
				value.cwd = __TS__StringTrim(value.cwd) -- 237
			end -- 237
		end -- 237
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 120 or 1800) -- 239
		return {success = true, value = value} -- 240
	end -- 240
	if tool == "list_sub_agents" then -- 240
		if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 240
			value.status = __TS__StringTrim(value.status) -- 243
		end -- 243
		value.limit = clampInteger(value.limit, 5, 1) -- 244
		value.offset = clampInteger(value.offset, 0, 0) -- 245
		if type(value.query) == "string" then -- 245
			value.query = __TS__StringTrim(value.query) -- 246
		end -- 246
		return {success = true, value = value} -- 247
	end -- 247
	if tool == "spawn_sub_agent" then -- 247
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 250
		local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 251
		if prompt == "" then -- 251
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 252
		end -- 252
		if title == "" then -- 252
			return {success = false, message = "spawn_sub_agent requires title"} -- 253
		end -- 253
		value.prompt = prompt -- 254
		value.title = title -- 255
		if type(value.expectedOutput) == "string" then -- 255
			value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 256
		end -- 256
		if __TS__ArrayIsArray(value.filesHint) then -- 256
			value.filesHint = __TS__ArrayMap( -- 258
				__TS__ArrayFilter( -- 258
					value.filesHint, -- 258
					function(____, item) return type(item) == "string" end -- 258
				), -- 258
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 258
			) -- 258
		end -- 258
		return {success = true, value = value} -- 260
	end -- 260
	return {success = true, value = value} -- 262
end -- 87
____exports.AGENT_TOOL_VALIDATORS = { -- 265
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 266
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 267
	delete_file = function(value) return ____exports.validateAgentToolInput("delete_file", value) end, -- 268
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 269
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 270
	glob_files = function(value) return ____exports.validateAgentToolInput("glob_files", value) end, -- 271
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 272
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 273
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 274
	list_sub_agents = function(value) return ____exports.validateAgentToolInput("list_sub_agents", value) end, -- 275
	spawn_sub_agent = function(value) return ____exports.validateAgentToolInput("spawn_sub_agent", value) end, -- 276
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 277
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 278
} -- 278
return ____exports -- 278