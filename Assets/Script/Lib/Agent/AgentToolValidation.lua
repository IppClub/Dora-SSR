-- [ts]: AgentToolValidation.ts
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
local AgentConfig = require("Agent.AgentConfig") -- 2
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 3
local normalizeQuestionnaire = ____AgentQuestionnaire.normalizeQuestionnaire -- 3
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
local function getFinishMessage(input) -- 62
	local candidates = {input.message, input.response, input.summary} -- 63
	do -- 63
		local i = 0 -- 64
		while i < #candidates do -- 64
			if type(candidates[i + 1]) == "string" and __TS__StringTrim(candidates[i + 1]) ~= "" then -- 64
				return __TS__StringTrim(candidates[i + 1]) -- 66
			end -- 66
			i = i + 1 -- 64
		end -- 64
	end -- 64
	return "" -- 69
end -- 62
function ____exports.validateAgentToolInput(tool, input) -- 72
	local value = __TS__ObjectAssign({}, input) -- 73
	if tool == "finish" then -- 73
		local message = getFinishMessage(value) -- 75
		if message == "" then -- 75
			return {success = false, message = "finish requires params.message"} -- 76
		end -- 76
		local completion = AgentUtils.normalizeAgentCompletionReport(value) -- 77
		value.message = message -- 78
		value.outcome = completion.outcome -- 79
		value.validation = completion.validation -- 80
		value.knownIssues = completion.knownIssues -- 81
		value.assumptions = completion.assumptions -- 82
		value.learningCandidates = completion.learningCandidates -- 83
		return {success = true, value = value} -- 84
	end -- 84
	if tool == "ask_user" then -- 84
		local normalized = normalizeQuestionnaire(value) -- 87
		return normalized.success and ({success = true, value = normalized.schema}) or normalized -- 88
	end -- 88
	if tool == "read_file" then -- 88
		if not __TS__ArrayIsArray(value.reads) or #value.reads < 1 then -- 88
			return {success = false, message = "read_file requires a non-empty reads array"} -- 93
		end -- 93
		local source = value.reads -- 94
		local reads = {} -- 95
		do -- 95
			local i = 0 -- 96
			while i < #source do -- 96
				local item = source[i + 1] -- 97
				local path = type(item.path) == "string" and __TS__StringTrim(item.path) or "" -- 98
				if path == "" then -- 98
					return { -- 99
						success = false, -- 99
						message = "read_file requires path at index " .. tostring(i) -- 99
					} -- 99
				end -- 99
				local start = parseReadLine(item.startLine, 1, "startLine") -- 100
				if start.success == false then -- 100
					return { -- 101
						success = false, -- 101
						message = (start.message .. " at index ") .. tostring(i) -- 101
					} -- 101
				end -- 101
				local ____end = parseReadLine(item.endLine, start.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit, "endLine") -- 102
				if ____end.success == false then -- 102
					return { -- 103
						success = false, -- 103
						message = (____end.message .. " at index ") .. tostring(i) -- 103
					} -- 103
				end -- 103
				reads[#reads + 1] = {path = path, startLine = start.value, endLine = ____end.value} -- 104
				i = i + 1 -- 96
			end -- 96
		end -- 96
		value.reads = reads -- 106
		return {success = true, value = value} -- 107
	end -- 107
	if tool == "edit_file" then -- 107
		local hasBatch = __TS__ArrayIsArray(value.edits) -- 110
		local hasLegacyPayload = value.old_str ~= nil or value.new_str ~= nil -- 111
		if hasBatch and hasLegacyPayload or not hasBatch and not hasLegacyPayload then -- 111
			return {success = false, message = "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str"} -- 113
		end -- 113
		local edits = ____exports.getAgentFileEditInputs(value) -- 115
		if #edits < 1 then -- 115
			return {success = false, message = "edit_file edits must not be empty"} -- 117
		end -- 117
		if not hasBatch then -- 117
			if edits[1].path == "" then -- 117
				return {success = false, message = "edit_file requires path"} -- 120
			end -- 120
			if edits[1].oldStr == edits[1].newStr then -- 120
				return {success = false, message = "edit_file requires old_str and new_str to differ"} -- 121
			end -- 121
		end -- 121
		if hasBatch then -- 121
			value.edits = __TS__ArrayMap( -- 124
				edits, -- 124
				function(____, edit) return {path = edit.path, old_str = edit.oldStr, new_str = edit.newStr} end -- 124
			) -- 124
		else -- 124
			value.path = edits[1].path -- 126
			value.old_str = edits[1].oldStr -- 127
			value.new_str = edits[1].newStr -- 128
		end -- 128
		return {success = true, value = value} -- 130
	end -- 130
	if tool == "delete_file" then -- 130
		local target = getDecisionPath(value) -- 133
		if target == "" then -- 133
			return {success = false, message = "delete_file requires target_file"} -- 134
		end -- 134
		value.target_file = target -- 135
		return {success = true, value = value} -- 136
	end -- 136
	if tool == "grep_files" or tool == "search_dora_doc" then -- 136
		local pattern = type(value.pattern) == "string" and __TS__StringTrim(value.pattern) or "" -- 139
		if pattern == "" then -- 139
			return {success = false, message = tool .. " requires pattern"} -- 140
		end -- 140
		value.pattern = pattern -- 141
		if tool == "grep_files" then -- 141
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 143
			value.offset = clampInteger(value.offset, 0, 0) -- 144
		else -- 144
			local docType = type(value.docType) == "string" and value.docType or "dora-api" -- 146
			if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 146
				return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 148
			end -- 148
			value.docType = docType -- 150
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 151
		end -- 151
		return {success = true, value = value} -- 153
	end -- 153
	if tool == "glob_files" then -- 153
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 156
		return {success = true, value = value} -- 157
	end -- 157
	if tool == "build" then -- 157
		if not __TS__ArrayIsArray(value.paths) then -- 157
			return {success = false, message = "build requires a non-empty paths array"} -- 160
		end -- 160
		local paths = __TS__ArrayMap( -- 161
			value.paths, -- 161
			function(____, item) return type(item) == "string" and __TS__StringTrim(item) or "" end -- 161
		) -- 161
		if #paths < 1 or __TS__ArraySome( -- 161
			paths, -- 162
			function(____, path) return path == "" end -- 162
		) then -- 162
			return {success = false, message = "build paths must contain non-empty paths"} -- 162
		end -- 162
		value.paths = paths -- 163
		return {success = true, value = value} -- 164
	end -- 164
	if tool == "fetch_url" then -- 164
		local url = type(value.url) == "string" and __TS__StringTrim(value.url) or "" -- 167
		local target = type(value.target) == "string" and __TS__StringTrim(value.target) or "" -- 168
		if url == "" then -- 168
			return {success = false, message = "fetch_url requires url"} -- 169
		end -- 169
		if target == "" then -- 169
			return {success = false, message = "fetch_url requires target"} -- 170
		end -- 170
		value.url = url -- 171
		value.target = target -- 172
		return {success = true, value = value} -- 173
	end -- 173
	if tool == "execute_command" then -- 173
		local mode = type(value.mode) == "string" and __TS__StringTrim(value.mode) or "" -- 176
		if mode ~= "lua" and mode ~= "git" then -- 176
			return {success = false, message = "execute_command requires mode: lua or git"} -- 177
		end -- 177
		value.mode = mode -- 178
		if mode == "lua" then -- 178
			local code = type(value.code) == "string" and value.code or "" -- 180
			if __TS__StringTrim(code) == "" then -- 180
				return {success = false, message = "execute_command lua mode requires code"} -- 181
			end -- 181
			value.code = code -- 182
		else -- 182
			local command = type(value.command) == "string" and __TS__StringTrim(value.command) or "" -- 184
			if command == "" then -- 184
				return {success = false, message = "execute_command git mode requires command"} -- 185
			end -- 185
			value.command = command -- 186
			if type(value.cwd) == "string" then -- 186
				value.cwd = __TS__StringTrim(value.cwd) -- 187
			end -- 187
		end -- 187
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode == "lua" and 30 or 600, 1, mode == "lua" and 120 or 1800) -- 189
		return {success = true, value = value} -- 190
	end -- 190
	if tool == "list_sub_agents" then -- 190
		if type(value.status) == "string" and __TS__StringTrim(value.status) ~= "" then -- 190
			value.status = __TS__StringTrim(value.status) -- 193
		end -- 193
		value.limit = clampInteger(value.limit, 5, 1) -- 194
		value.offset = clampInteger(value.offset, 0, 0) -- 195
		if type(value.query) == "string" then -- 195
			value.query = __TS__StringTrim(value.query) -- 196
		end -- 196
		return {success = true, value = value} -- 197
	end -- 197
	if tool == "spawn_sub_agent" then -- 197
		local prompt = type(value.prompt) == "string" and __TS__StringTrim(value.prompt) or "" -- 200
		local title = type(value.title) == "string" and __TS__StringTrim(value.title) or "" -- 201
		if prompt == "" then -- 201
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 202
		end -- 202
		if title == "" then -- 202
			return {success = false, message = "spawn_sub_agent requires title"} -- 203
		end -- 203
		value.prompt = prompt -- 204
		value.title = title -- 205
		if type(value.expectedOutput) == "string" then -- 205
			value.expectedOutput = __TS__StringTrim(value.expectedOutput) -- 206
		end -- 206
		if __TS__ArrayIsArray(value.filesHint) then -- 206
			value.filesHint = __TS__ArrayMap( -- 208
				__TS__ArrayFilter( -- 208
					value.filesHint, -- 208
					function(____, item) return type(item) == "string" end -- 208
				), -- 208
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 208
			) -- 208
		end -- 208
		return {success = true, value = value} -- 210
	end -- 210
	return {success = true, value = value} -- 212
end -- 72
____exports.AGENT_TOOL_VALIDATORS = { -- 215
	read_file = function(value) return ____exports.validateAgentToolInput("read_file", value) end, -- 216
	edit_file = function(value) return ____exports.validateAgentToolInput("edit_file", value) end, -- 217
	delete_file = function(value) return ____exports.validateAgentToolInput("delete_file", value) end, -- 218
	grep_files = function(value) return ____exports.validateAgentToolInput("grep_files", value) end, -- 219
	search_dora_doc = function(value) return ____exports.validateAgentToolInput("search_dora_doc", value) end, -- 220
	glob_files = function(value) return ____exports.validateAgentToolInput("glob_files", value) end, -- 221
	build = function(value) return ____exports.validateAgentToolInput("build", value) end, -- 222
	fetch_url = function(value) return ____exports.validateAgentToolInput("fetch_url", value) end, -- 223
	execute_command = function(value) return ____exports.validateAgentToolInput("execute_command", value) end, -- 224
	list_sub_agents = function(value) return ____exports.validateAgentToolInput("list_sub_agents", value) end, -- 225
	spawn_sub_agent = function(value) return ____exports.validateAgentToolInput("spawn_sub_agent", value) end, -- 226
	ask_user = function(value) return ____exports.validateAgentToolInput("ask_user", value) end, -- 227
	finish = function(value) return ____exports.validateAgentToolInput("finish", value) end -- 228
} -- 228
return ____exports -- 228