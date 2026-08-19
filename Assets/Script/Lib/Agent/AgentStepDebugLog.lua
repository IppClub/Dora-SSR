-- [ts]: AgentStepDebugLog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Path = ____Dora.Path -- 1
local Content = ____Dora.Content -- 1
local AgentUtils = require("Agent.Utils") -- 2
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 4
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 4
local function canWriteStepLLMDebug(shared, stepId) -- 13
	if stepId == nil then -- 13
		stepId = shared.step + 1 -- 13
	end -- 13
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 14
end -- 13
local function ensureDirRecursive(dir) -- 21
	if not dir then -- 21
		return false -- 22
	end -- 22
	if Content:exist(dir) then -- 22
		return Content:isdir(dir) -- 23
	end -- 23
	local parent = Path:getPath(dir) -- 24
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 24
		return false -- 26
	end -- 26
	return Content:mkdir(dir) -- 28
end -- 21
function ____exports.encodeDebugJSON(value) -- 31
	local text, err = AgentUtils.safeJsonEncode(value) -- 32
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 33
end -- 31
local function getStepLLMDebugDir(shared) -- 36
	return Path( -- 37
		shared.workingDir, -- 38
		".agent", -- 39
		tostring(shared.sessionId), -- 40
		tostring(shared.taskId) -- 41
	) -- 41
end -- 36
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 45
	return Path( -- 46
		getStepLLMDebugDir(shared), -- 46
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 46
	) -- 46
end -- 45
local function getLatestStepLLMDebugSeq(shared, stepId) -- 49
	if not canWriteStepLLMDebug(shared, stepId) then -- 49
		return 0 -- 50
	end -- 50
	local dir = getStepLLMDebugDir(shared) -- 51
	if not Content:exist(dir) or not Content:isdir(dir) then -- 51
		return 0 -- 52
	end -- 52
	local latest = 0 -- 53
	for ____, file in ipairs(Content:getFiles(dir)) do -- 54
		do -- 54
			local name = Path:getFilename(file) -- 55
			local seqText = string.match( -- 56
				name, -- 56
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 56
			) -- 56
			if seqText ~= nil then -- 56
				latest = math.max( -- 58
					latest, -- 58
					tonumber(seqText) -- 58
				) -- 58
				goto __continue13 -- 59
			end -- 59
			local legacyMatch = string.match( -- 61
				name, -- 61
				("^" .. tostring(stepId)) .. "_in%.md$" -- 61
			) -- 61
			if legacyMatch ~= nil then -- 61
				latest = math.max(latest, 1) -- 63
			end -- 63
		end -- 63
		::__continue13:: -- 63
	end -- 63
	return latest -- 66
end -- 49
local function writeStepLLMDebugFile(path, content) -- 69
	if not Content:save(path, content) then -- 69
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 71
		return false -- 72
	end -- 72
	sendWebIDEFileUpdate(path, true, content) -- 74
	return true -- 75
end -- 69
local function createStepLLMDebugPair(shared, stepId, inContent) -- 78
	if not canWriteStepLLMDebug(shared, stepId) then -- 78
		return 0 -- 79
	end -- 79
	local dir = getStepLLMDebugDir(shared) -- 80
	if not ensureDirRecursive(dir) then -- 80
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 82
		return 0 -- 83
	end -- 83
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 85
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 86
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 87
	if not writeStepLLMDebugFile(inPath, inContent) then -- 87
		return 0 -- 89
	end -- 89
	writeStepLLMDebugFile(outPath, "") -- 91
	return seq -- 92
end -- 78
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 95
	if not canWriteStepLLMDebug(shared, stepId) then -- 95
		return -- 96
	end -- 96
	local dir = getStepLLMDebugDir(shared) -- 97
	if not ensureDirRecursive(dir) then -- 97
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 99
		return -- 100
	end -- 100
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 102
	if latestSeq <= 0 then -- 102
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 104
		writeStepLLMDebugFile(outPath, content) -- 105
		return -- 106
	end -- 106
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 108
	writeStepLLMDebugFile(outPath, content) -- 109
end -- 95
function ____exports.saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 112
	if not canWriteStepLLMDebug(shared, stepId) then -- 112
		return -- 113
	end -- 113
	local sections = { -- 114
		"# LLM Input", -- 115
		"session_id: " .. tostring(shared.sessionId), -- 116
		"task_id: " .. tostring(shared.taskId), -- 117
		"step_id: " .. tostring(stepId), -- 118
		"phase: " .. phase, -- 119
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 120
		"## Options", -- 121
		"```json", -- 122
		____exports.encodeDebugJSON(options), -- 123
		"```" -- 124
	} -- 124
	local firstMessage = #messages > 0 and messages[1] or nil -- 126
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 126
		sections[#sections + 1] = "# System Prompt" -- 128
		sections[#sections + 1] = firstMessage.content -- 129
	end -- 129
	do -- 129
		local i = 0 -- 131
		while i < #messages do -- 131
			local message = messages[i + 1] -- 132
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 133
			sections[#sections + 1] = ____exports.encodeDebugJSON(message) -- 134
			i = i + 1 -- 131
		end -- 131
	end -- 131
	createStepLLMDebugPair( -- 136
		shared, -- 136
		stepId, -- 136
		table.concat(sections, "\n") -- 136
	) -- 136
end -- 112
function ____exports.saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 139
	if not canWriteStepLLMDebug(shared, stepId) then -- 139
		return -- 140
	end -- 140
	local ____array_0 = __TS__SparseArrayNew( -- 140
		"# LLM Output", -- 142
		"session_id: " .. tostring(shared.sessionId), -- 143
		"task_id: " .. tostring(shared.taskId), -- 144
		"step_id: " .. tostring(stepId), -- 145
		"phase: " .. phase, -- 146
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 147
		table.unpack(meta and ({ -- 148
			"## Meta", -- 148
			"```json", -- 148
			____exports.encodeDebugJSON(meta), -- 148
			"```" -- 148
		}) or ({})) -- 148
	) -- 148
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 148
	local sections = {__TS__SparseArraySpread(____array_0)} -- 141
	updateLatestStepLLMDebugOutput( -- 152
		shared, -- 152
		stepId, -- 152
		table.concat(sections, "\n") -- 152
	) -- 152
end -- 139
return ____exports -- 139