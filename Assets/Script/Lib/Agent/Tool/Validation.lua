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
	if tool == "write_file" then -- 146
		if __TS__ArrayIsArray(value.edits) then -- 146
			return {success = false, message = "write_file does not support batch edits"} -- 149
		end -- 149
		if value.delete == true then -- 149
			return {success = false, message = "write_file cannot delete; use edit_file delete"} -- 150
		end -- 150
		if value.old_str ~= nil then -- 150
			return {success = false, message = "write_file does not take old_str; it writes the complete file"} -- 151
		end -- 151
		local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 152
		if path == "" then -- 152
			return {success = false, message = "write_file requires path"} -- 153
		end -- 153
		value.path = path -- 154
		value.new_str = type(value.new_str) == "string" and value.new_str or "" -- 155
		return {success = true, value = value} -- 156
	end -- 156
	if tool == "edit_file" then -- 156
		if value.delete == true then -- 156
			if __TS__ArrayIsArray(value.edits) then -- 156
				return {success = false, message = "edit_file delete cannot be combined with edits; call delete separately"} -- 161
			end -- 161
			if value.old_str ~= nil or value.new_str ~= nil then -- 161
				return {success = false, message = "edit_file delete cannot be combined with old_str/new_str"} -- 162
			end -- 162
			local target = getDecisionPath(value) -- 163
			if target == "" then -- 163
				return {success = false, message = "edit_file delete requires path"} -- 164
			end -- 164
			value.path = target -- 165
			value.target_file = nil -- 166
			return {success = true, value = value} -- 167
		end -- 167
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 169
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 170
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 170
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 172
		end -- 172
		local edits = ____exports.getAgentFileEditInputs(value) -- 174
		if #edits < 1 then -- 174
			return {success = false, message = "edit_file edits must not be empty"} -- 176
		end -- 176
		if not hasBatch then -- 176
			if edits[1].path == "" then -- 176
				return {success = false, message = "edit_file requires path"} -- 179
			end -- 179
			if edits[1].oldStr == "" then -- 179
				return {success = false, message = "edit_file requires a non-empty old_str anchor; use write_file to create or rewrite a whole file"} -- 180
			end -- 180
			if edits[1].oldStr == edits[1].newStr then -- 180
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 181
			end -- 181
		end -- 181
		if hasBatch then -- 181
			do -- 181
				local i = 0 -- 184
				while i < #edits do -- 184
					if edits[i + 1].oldStr == "" then -- 184
						return {success = false, message = "batch entry requires non-empty old_str; use write_file for whole-file creation or rewrite"} -- 185
					end -- 185
					i = i + 1 -- 184
				end -- 184
			end -- 184
			value.edits = __TS__ArrayMap( -- 187
				edits, -- 187
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 187
			) -- 187
		else -- 187
			value.path = edits[1].path -- 189
			value.old_str = edits[1].oldStr -- 190
			value.new_str = edits[1].newStr -- 191
		end -- 191
		return {success = true, value = value} -- 193
	end -- 193
	if tool == "grep_files" or tool == "search_dora_doc" then -- 193
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 196
		if pattern == "" and tool == "search_dora_doc" then -- 196
			return {success = false, message = tool .. " requires pattern"} -- 197
		end -- 197
		local ____temp_5 -- 198
		if pattern == "" then -- 198
			____temp_5 = nil -- 198
		else -- 198
			____temp_5 = pattern -- 198
		end -- 198
		value.pattern = ____temp_5 -- 198
		if tool == "grep_files" then -- 198
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 200
			value.offset = clampInteger(value.offset, 0, 0) -- 201
			value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 202
		else -- 202
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 204
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 204
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 206
			end -- 206
			value.docType = docType -- 208
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 209
		end -- 209
		return {success = true, value = value} -- 211
	end -- 211
	if tool == "build" then -- 211
		local hasPaths = value.paths ~= nil -- 214
		local hasPath = value.path ~= nil -- 215
		if not hasPaths and not hasPath then -- 215
			return {success = false, message = "build requires paths or path"} -- 216
		end -- 216
		local paths = {} -- 217
		if hasPath then -- 217
			local path = type(value.path) == "string" and __TS__StringTrim(value.path) or "" -- 219
			if path == "" then -- 219
				return {success = false, message = "build path must be non-empty"} -- 220
			end -- 220
			paths[#paths + 1] = path -- 221
		end -- 221
		if hasPaths then -- 221
			if not __TS__ArrayIsArray(value.paths) then -- 221
				return {success = false, message = "build paths must be a non-empty array"} -- 224
			end -- 224
			local arrayPaths = __TS__ArrayMap( -- 225
				value.paths, -- 225
				function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 225
			) -- 225
			if #arrayPaths < 1 or __TS__ArraySome( -- 225
				arrayPaths, -- 226
				function(____, path) return path == "" end -- 226
			) then -- 226
				return {success = false, message = "build paths must contain non-empty paths"} -- 227
			end -- 227
			do -- 227
				local i = 0 -- 229
				while i < #arrayPaths do -- 229
					paths[#paths + 1] = arrayPaths[i + 1] -- 229
					i = i + 1 -- 229
				end -- 229
			end -- 229
		end -- 229
		value.path = nil -- 231
		value.paths = paths -- 232
		return {success = true, value = value} -- 233
	end -- 233
	if tool == "fetch_url" then -- 233
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 236
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 237
		if url == "" then -- 237
			return {success = false, message = "fetch_url requires url"} -- 238
		end -- 238
		if target == "" then -- 238
			return {success = false, message = "fetch_url requires target"} -- 239
		end -- 239
		value.url = url -- 240
		value.target = target -- 241
		return {success = true, value = value} -- 242
	end -- 242
	if tool == "analyze_image" then -- 242
		local function imageExt(path) -- 245
			local ext = string.lower(Path:getExt(path)) -- 246
			return ext == "png" or ext == "jpg" or ext == "jpeg" -- 247
		end -- 245
		if not __TS__ArrayIsArray(value.paths) or #value.paths < 1 or #value.paths > 3 or __TS__ArraySome( -- 245
			value.paths, -- 249
			function(____, item) return type(item) ~= "string" or __TS__StringTrim(item) == "" or not isValidWorkspacePath(__TS__StringTrim(item)) or not imageExt(__TS__StringTrim(item)) end -- 249
		) then -- 249
			return {success = false, message = "analyze_image requires 1–3 project-relative PNG/JPEG image paths"} -- 250
		end -- 250
		value.paths = __TS__ArrayMap( -- 252
			value.paths, -- 252
			function(____, item) return __TS__StringTrim(item) end -- 252
		) -- 252
		for ____, name in ipairs({"question", "criteria", "context"}) do -- 253
			do -- 253
				local text = value[name] -- 254
				if (name == "criteria" or name == "context") and text == nil then -- 254
					goto __continue86 -- 255
				end -- 255
				if type(text) ~= "string" or name == "question" and __TS__StringTrim(text) == "" then -- 255
					return {success = false, message = name .. " must be valid text"} -- 256
				end -- 256
				local length = utf8.len(text) -- 257
				if length == nil or length > 4000 then -- 257
					return {success = false, message = name .. " must contain at most 4000 Unicode characters"} -- 258
				end -- 258
			end -- 258
			::__continue86:: -- 258
		end -- 258
		return {success = true, value = value} -- 260
	end -- 260
	if tool == "execute_command" then -- 260
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 263
		if mode ~= "lua" and mode ~= "git" then -- 263
			return {success = false, message = "execute_command requires mode: lua or git"} -- 264
		end -- 264
		value.mode = mode -- 265
		if mode == "lua" then -- 265
			local code = type(value.code) == "string" and value.code or "" -- 267
			if __TS__StringTrim(code) == "" then -- 267
				return {success = false, message = "execute_command lua mode requires code"} -- 268
			end -- 268
			value.code = code -- 269
		else -- 269
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 271
			if command == "" then -- 271
				return {success = false, message = "execute_command git mode requires command"} -- 272
			end -- 272
			value.command = command -- 273
			if type(value.cwd) == "string" then -- 273
				value.cwd = __TS__StringTrim(value.cwd) -- 274
			end -- 274
		end -- 274
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 600 or 1800) -- 276
		return {success = true, value = value} -- 277
	end -- 277
	if tool == "spawn_agent" then -- 277
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 280
		if prompt ~= "" then -- 280
			if value.status ~= nil or value.limit ~= nil or value.offset ~= nil or value.query ~= nil then -- 280
				return {success = false, message = "spawn_agent spawn form cannot combine the list filters (status/limit/offset/query)"} -- 284
			end -- 284
			local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 286
			if title == "" then -- 286
				return {success = false, message = "spawn_agent spawn form requires title"} -- 287
			end -- 287
			value.prompt = prompt -- 288
			value.title = title -- 289
			if type(value.expectedOutput) == "string" then -- 289
				value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 290
			end -- 290
			if __TS__ArrayIsArray(value.filesHint) then -- 290
				value.filesHint = __TS__ArrayMap( -- 292
					__TS__ArrayFilter( -- 292
						value.filesHint, -- 292
						function(____, item) return type(item) == "string" end -- 292
					), -- 292
					function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 292
				) -- 292
			end -- 292
		else -- 292
			if value.title ~= nil or value.expectedOutput ~= nil or value.filesHint ~= nil then -- 292
				return {success = false, message = "spawn_agent list form cannot carry spawn fields (title/expectedOutput/filesHint)"} -- 297
			end -- 297
			value.prompt = nil -- 299
			value.title = nil -- 300
			if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 300
				value.status = __TS__StringTrim(value.status) -- 301
			end -- 301
			value.limit = clampInteger(value.limit, 5, 1) -- 302
			value.offset = clampInteger(value.offset, 0, 0) -- 303
			if type(value.query) == "string" then -- 303
				value.query = __TS__StringTrim(value.query) -- 304
			end -- 304
		end -- 304
		return {success = true, value = value} -- 306
	end -- 306
	return {success = true, value = value} -- 308
end -- 91
____exports.AGENT_TOOL_VALIDATORS = { -- 311
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 312
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 313
	write_file = function(value) return ____exports.validateAgentToolInput("write_file", value) end, -- 314
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 315
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 316
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 317
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 318
	analyze_image = function(value) return ____exports.validateAgentToolInput("analyze_image", value) end, -- 319
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 320
	spawn_agent = function(value) return ____exports.validateAgentToolInput("spawn_agent", value) end, -- 321
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 322
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 323
} -- 323
return ____exports -- 323