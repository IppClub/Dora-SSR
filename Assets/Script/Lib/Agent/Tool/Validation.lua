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
local AgentConfig = require("Agent.Config.Defaults") -- 3
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 4
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 4
local AgentUtils = require("Agent.Utils") -- 5
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
	if tool == "ask_user" then -- 92
		local normalized = normalizeQuestionnaire(value) -- 94
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 95
	end -- 95
	if tool == "read_file" then -- 95
		local hasReads = value.reads ~= nil -- 100
		local hasPath = value.path ~= nil -- 101
		if not hasReads and not hasPath then -- 101
			return {success = false, message = "read_file requires path or reads"} -- 103
		end -- 103
		if not hasPath and (value.startLine ~= nil or value.endLine ~= nil) then -- 103
			return {success = false, message = "read_file startLine/endLine require a top-level path"} -- 106
		end -- 106
		local reads = {} -- 108
		if hasPath then -- 108
			local normalized = normalizeReadRange(value) -- 110
			if normalized.success == false then -- 110
				return normalized -- 111
			end -- 111
			reads[#reads + 1] = normalized.value -- 112
		end -- 112
		if hasReads then -- 112
			if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 112
				return {success = false, message = "read_file reads must be a non-empty array"} -- 116
			end -- 116
			do -- 116
				local i = 0 -- 118
				while i < #value.reads do -- 118
					local normalized = normalizeReadRange(value.reads[i + 1], i) -- 119
					if normalized.success == false then -- 119
						return normalized -- 120
					end -- 120
					reads[#reads + 1] = normalized.value -- 121
					i = i + 1 -- 118
				end -- 118
			end -- 118
		end -- 118
		if not hasReads then -- 118
			value.path = reads[1].path -- 125
			value.startLine = reads[1].startLine -- 126
			value.endLine = reads[1].endLine -- 127
			return {success = true, value = value} -- 128
		end -- 128
		value.path = nil -- 130
		value.startLine = nil -- 131
		value.endLine = nil -- 132
		value.reads = reads -- 133
		return {success = true, value = value} -- 134
	end -- 134
	if tool == "write_file" then -- 134
		if __TS__ArrayIsArray(value.edits) then -- 134
			return {success = false, message = "write_file does not support batch edits"} -- 137
		end -- 137
		if value.delete == true then -- 137
			return {success = false, message = "write_file cannot delete; use edit_file delete"} -- 138
		end -- 138
		if value.old_str ~= nil then -- 138
			return {success = false, message = "write_file does not take old_str; it writes the complete file"} -- 139
		end -- 139
		local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 140
		if path == "" then -- 140
			return {success = false, message = "write_file requires path"} -- 141
		end -- 141
		value.path = path -- 142
		value.new_str = type(value.new_str) == "string" and value.new_str or "" -- 143
		return {success = true, value = value} -- 144
	end -- 144
	if tool == "edit_file" then -- 144
		if value.delete == true then -- 144
			if __TS__ArrayIsArray(value.edits) then -- 144
				return {success = false, message = "edit_file delete cannot be combined with edits; call delete separately"} -- 149
			end -- 149
			if value.old_str ~= nil or value.new_str ~= nil then -- 149
				return {success = false, message = "edit_file delete cannot be combined with old_str/new_str"} -- 150
			end -- 150
			local target = getDecisionPath(value) -- 151
			if target == "" then -- 151
				return {success = false, message = "edit_file delete requires path"} -- 152
			end -- 152
			value.path = target -- 153
			value.target_file = nil -- 154
			return {success = true, value = value} -- 155
		end -- 155
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 157
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 158
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 158
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 160
		end -- 160
		local edits = ____exports.getAgentFileEditInputs(value) -- 162
		if #edits < 1 then -- 162
			return {success = false, message = "edit_file edits must not be empty"} -- 164
		end -- 164
		if not hasBatch then -- 164
			if edits[1].path == "" then -- 164
				return {success = false, message = "edit_file requires path"} -- 167
			end -- 167
			if edits[1].oldStr == "" then -- 167
				return {success = false, message = "edit_file requires a non-empty old_str anchor; use write_file to create or rewrite a whole file"} -- 168
			end -- 168
			if edits[1].oldStr == edits[1].newStr then -- 168
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 169
			end -- 169
		end -- 169
		if hasBatch then -- 169
			do -- 169
				local i = 0 -- 172
				while i < #edits do -- 172
					if edits[i + 1].oldStr == "" then -- 172
						return {success = false, message = "batch entry requires non-empty old_str; use write_file for whole-file creation or rewrite"} -- 173
					end -- 173
					i = i + 1 -- 172
				end -- 172
			end -- 172
			value.edits = __TS__ArrayMap( -- 175
				edits, -- 175
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 175
			) -- 175
		else -- 175
			value.path = edits[1].path -- 177
			value.old_str = edits[1].oldStr -- 178
			value.new_str = edits[1].newStr -- 179
		end -- 179
		return {success = true, value = value} -- 181
	end -- 181
	if tool == "grep_files" or tool == "search_dora_doc" then -- 181
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 184
		if pattern == "" and tool == "search_dora_doc" then -- 184
			return {success = false, message = tool .. " requires pattern"} -- 185
		end -- 185
		local ____temp_5 -- 186
		if pattern == "" then -- 186
			____temp_5 = nil -- 186
		else -- 186
			____temp_5 = pattern -- 186
		end -- 186
		value.pattern = ____temp_5 -- 186
		if tool == "grep_files" then -- 186
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 188
			value.offset = clampInteger(value.offset, 0, 0) -- 189
			value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 190
		else -- 190
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 192
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 192
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 194
			end -- 194
			value.docType = docType -- 196
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 197
		end -- 197
		return {success = true, value = value} -- 199
	end -- 199
	if tool == "build" then -- 199
		local hasPaths = value.paths ~= nil -- 202
		local hasPath = value.path ~= nil -- 203
		if not hasPaths and not hasPath then -- 203
			return {success = false, message = "build requires paths or path"} -- 204
		end -- 204
		local paths = {} -- 205
		if hasPath then -- 205
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 207
			if path == "" then -- 207
				return {success = false, message = "build path must be non-empty"} -- 208
			end -- 208
			paths[#paths + 1] = path -- 209
		end -- 209
		if hasPaths then -- 209
			if not __TS__ArrayIsArray(value.paths) then -- 209
				return {success = false, message = "build paths must be a non-empty array"} -- 212
			end -- 212
			local arrayPaths = __TS__ArrayMap( -- 213
				value.paths, -- 213
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 213
			) -- 213
			if #arrayPaths < 1 or __TS__ArraySome( -- 213
				arrayPaths, -- 214
				function(____, path) return path == "" end -- 214
			) then -- 214
				return {success = false, message = "build paths must contain non-empty paths"} -- 215
			end -- 215
			do -- 215
				local i = 0 -- 217
				while i < #arrayPaths do -- 217
					paths[#paths + 1] = arrayPaths[i + 1] -- 217
					i = i + 1 -- 217
				end -- 217
			end -- 217
		end -- 217
		value.path = nil -- 219
		value.paths = paths -- 220
		return {success = true, value = value} -- 221
	end -- 221
	if tool == "fetch_url" then -- 221
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 224
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 225
		if url == "" then -- 225
			return {success = false, message = "fetch_url requires url"} -- 226
		end -- 226
		if target == "" then -- 226
			return {success = false, message = "fetch_url requires target"} -- 227
		end -- 227
		value.url = url -- 228
		value.target = target -- 229
		return {success = true, value = value} -- 230
	end -- 230
	if tool == "execute_command" then -- 230
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 233
		if mode ~= "lua" and mode ~= "git" then -- 233
			return {success = false, message = "execute_command requires mode: lua or git"} -- 234
		end -- 234
		value.mode = mode -- 235
		if mode == "lua" then -- 235
			local code = type(value.code) == "string" and value.code or "" -- 237
			if __TS__StringTrim(code) == "" then -- 237
				return {success = false, message = "execute_command lua mode requires code"} -- 238
			end -- 238
			value.code = code -- 239
		else -- 239
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 241
			if command == "" then -- 241
				return {success = false, message = "execute_command git mode requires command"} -- 242
			end -- 242
			value.command = command -- 243
			if type(value.cwd) == "string" then -- 243
				value.cwd = __TS__StringTrim(value.cwd) -- 244
			end -- 244
		end -- 244
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 600 or 1800) -- 246
		return {success = true, value = value} -- 247
	end -- 247
	if tool == "spawn_agent" then -- 247
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 250
		if prompt ~= "" then -- 250
			if value.status ~= nil or value.limit ~= nil or value.offset ~= nil or value.query ~= nil then -- 250
				return {success = false, message = "spawn_agent spawn form cannot combine the list filters (status/limit/offset/query)"} -- 254
			end -- 254
			local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 256
			if title == "" then -- 256
				return {success = false, message = "spawn_agent spawn form requires title"} -- 257
			end -- 257
			value.prompt = prompt -- 258
			value.title = title -- 259
			if type(value.expectedOutput) == "string" then -- 259
				value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 260
			end -- 260
			if __TS__ArrayIsArray(value.filesHint) then -- 260
				value.filesHint = __TS__ArrayMap( -- 262
					__TS__ArrayFilter( -- 262
						value.filesHint, -- 262
						function(____, item) return type(item) == "string" end -- 262
					), -- 262
					function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 262
				) -- 262
			end -- 262
		else -- 262
			if value.title ~= nil or value.expectedOutput ~= nil or value.filesHint ~= nil then -- 262
				return {success = false, message = "spawn_agent list form cannot carry spawn fields (title/expectedOutput/filesHint)"} -- 267
			end -- 267
			value.prompt = nil -- 269
			value.title = nil -- 270
			if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 270
				value.status = __TS__StringTrim(value.status) -- 271
			end -- 271
			value.limit = clampInteger(value.limit, 5, 1) -- 272
			value.offset = clampInteger(value.offset, 0, 0) -- 273
			if type(value.query) == "string" then -- 273
				value.query = __TS__StringTrim(value.query) -- 274
			end -- 274
		end -- 274
		return {success = true, value = value} -- 276
	end -- 276
	return {success = true, value = value} -- 278
end -- 91
____exports.AGENT_TOOL_VALIDATORS = { -- 281
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 282
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 283
	write_file = function(value) return ____exports.validateAgentToolInput("write_file", value) end, -- 284
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 285
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 286
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 287
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 288
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 289
	spawn_agent = function(value) return ____exports.validateAgentToolInput("spawn_agent", value) end, -- 290
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end -- 291
} -- 291
return ____exports -- 291