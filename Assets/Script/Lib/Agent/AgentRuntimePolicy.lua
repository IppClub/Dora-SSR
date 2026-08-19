-- [ts]: AgentRuntimePolicy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 5
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 5
local Tools = require("Agent.Tools") -- 6
____exports.AGENT_PLAN_DIR = ".agent/plan" -- 8
____exports.AGENT_PLAN_FILE = ".agent/plan/PLAN.md" -- 9
____exports.AGENT_PROGRESS_FILE = ".agent/plan/PROGRESS.md" -- 10
local DEFAULT_PLAN_DOCUMENT = "# 开发方案\n\n## 目标\n\n## 背景与当前实现\n\n## 范围\n\n### 包含\n\n### 不包含\n\n## 已确认决策\n\n## 待确认问题\n\n无\n\n## 技术方案\n\n## 实施步骤\n\n| ID | 工作项 | 依赖 | 验收条件 |\n| --- | --- | --- | --- |\n\n## 风险与回退方案\n\n## 验证计划\n\n## 变更记录\n"
local DEFAULT_PROGRESS_DOCUMENT = "# 开发进度\n\n## 当前工作\n\n## 步骤进度\n\n| ID | 状态 | 最新结果 | 下一步 |\n| --- | --- | --- | --- |\n\n## 修改记录\n\n## 验证证据\n\n## 阻塞问题\n\n## 进度日志\n"
local function trimText(value) -- 62
	local trimmed = string.match(value, "^%s*(.-)%s*$") -- 63
	return trimmed or "" -- 64
end -- 62
function ____exports.normalizeAgentPath(path) -- 67
	local normalized = table.concat( -- 68
		__TS__StringSplit( -- 68
			trimText(path), -- 68
			"\\" -- 68
		), -- 68
		"/" -- 68
	) -- 68
	while __TS__StringStartsWith(normalized, "./") do -- 68
		normalized = string.sub(normalized, 3) -- 69
	end -- 69
	return normalized -- 70
end -- 67
function ____exports.getAgentDecisionPath(input) -- 73
	if type(input.path) == "string" then -- 73
		return __TS__StringTrim(input.path) -- 74
	end -- 74
	if type(input.target_file) == "string" then -- 74
		return __TS__StringTrim(input.target_file) -- 75
	end -- 75
	return "" -- 76
end -- 73
function ____exports.isMainAgentMemoryPath(path) -- 79
	local normalized = ____exports.normalizeAgentPath(path) -- 80
	return normalized == ".agent/main" or __TS__StringStartsWith(normalized, ".agent/main/") -- 81
end -- 79
function ____exports.isAgentPlanPath(path) -- 84
	local normalized = ____exports.normalizeAgentPath(path) -- 85
	return normalized == ____exports.AGENT_PLAN_DIR or __TS__StringStartsWith(normalized, ____exports.AGENT_PLAN_DIR .. "/") -- 86
end -- 84
function ____exports.isAgentInternalDocumentPath(path) -- 89
	return ____exports.isMainAgentMemoryPath(path) or ____exports.isAgentPlanPath(path) -- 90
end -- 89
local function ensureDirectory(dir) -- 93
	if Content:exist(dir) then -- 93
		return Content:isdir(dir) -- 94
	end -- 94
	local parent = Path:getPath(dir) -- 95
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirectory(parent) then -- 95
		return false -- 96
	end -- 96
	return Content:mkdir(dir) -- 97
end -- 93
function ____exports.ensureAgentPlanDocuments(workDir) -- 100
	local dir = Path(workDir, ____exports.AGENT_PLAN_DIR) -- 101
	if not ensureDirectory(dir) then -- 101
		return {success = false, message = "failed to create " .. ____exports.AGENT_PLAN_DIR} -- 102
	end -- 102
	local created = {} -- 103
	local documents = {{____exports.AGENT_PLAN_FILE, DEFAULT_PLAN_DOCUMENT}, {____exports.AGENT_PROGRESS_FILE, DEFAULT_PROGRESS_DOCUMENT}} -- 104
	do -- 104
		local i = 0 -- 108
		while i < #documents do -- 108
			do -- 108
				local relative, content = table.unpack(documents[i + 1], 1, 2) -- 109
				local path = Path(workDir, relative) -- 110
				if Content:exist(path) then -- 110
					goto __continue17 -- 111
				end -- 111
				if not Content:save(path, content) then -- 111
					return {success = false, message = "failed to create " .. relative} -- 112
				end -- 112
				sendWebIDEFileUpdate(path, true, content) -- 113
				created[#created + 1] = relative -- 114
			end -- 114
			::__continue17:: -- 114
			i = i + 1 -- 108
		end -- 108
	end -- 108
	return {success = true, created = created} -- 116
end -- 100
function ____exports.isEditBudgetExhausted(state) -- 127
	local mustCreateFreshEntry = state.freshProjectBuildPending == true and state.freshProjectCodeFile == nil and state.hasBuilt ~= true -- 128
	return state.unbuiltEdits == true and (state.editsSinceBuild or 0) >= 3 and not mustCreateFreshEntry -- 131
end -- 127
function ____exports.getUncoveredConversationMessages(messages, lastConsolidatedIndex) -- 136
	return __TS__ArraySlice(messages, lastConsolidatedIndex) -- 137
end -- 136
function ____exports.normalizeLineEndings(text) -- 140
	return table.concat( -- 141
		__TS__StringSplit( -- 141
			table.concat( -- 141
				__TS__StringSplit(text, "\r\n"), -- 141
				"\n" -- 141
			), -- 141
			"\r" -- 141
		), -- 141
		"\n" -- 141
	) -- 141
end -- 140
function ____exports.countOccurrences(text, needle) -- 144
	if needle == "" then -- 144
		return 0 -- 145
	end -- 145
	local count = 0 -- 146
	local start = 0 -- 147
	while start <= #text - #needle do -- 147
		local index = (string.find( -- 149
			text, -- 149
			needle, -- 149
			math.max(start + 1, 1), -- 149
			true -- 149
		) or 0) - 1 -- 149
		if index < 0 then -- 149
			break -- 150
		end -- 150
		count = count + 1 -- 151
		start = index + #needle -- 152
	end -- 152
	return count -- 154
end -- 144
function ____exports.containsWholeFileDuplicate(existing, replacement) -- 157
	local normalizedExisting = ____exports.normalizeLineEndings(existing) -- 158
	local normalizedReplacement = ____exports.normalizeLineEndings(replacement) -- 159
	if #normalizedExisting < 16 or #normalizedReplacement <= #normalizedExisting then -- 159
		return false -- 160
	end -- 160
	return ____exports.countOccurrences(normalizedReplacement, normalizedExisting) > 1 -- 161
end -- 157
function ____exports.successfulEditResult(workDir, path, base) -- 164
	local current = Tools.readFileRaw(workDir, path) -- 169
	local currentCharacters = current.success and type(current.content) == "string" and #current.content or 0 -- 170
	return __TS__ObjectAssign( -- 171
		{}, -- 171
		base, -- 172
		{ -- 171
			actualSaved = current.success, -- 173
			actualSavedCharacters = currentCharacters, -- 174
			currentFileExists = current.success, -- 175
			currentCharacters = currentCharacters, -- 176
			currentState = current.success and (("saved " .. tostring(currentCharacters)) .. " characters to ") .. path or "file state unavailable after edit: " .. sanitizeUTF8(current.message) -- 177
		} -- 177
	) -- 177
end -- 164
return ____exports -- 164