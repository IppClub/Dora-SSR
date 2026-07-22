-- [ts]: AgentRuntimePolicy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local Tools = require("Agent.Tools") -- 5
____exports.AGENT_PLAN_DIR = ".agent/plan" -- 7
____exports.AGENT_PLAN_FILE = ".agent/plan/PLAN.md" -- 8
____exports.AGENT_PROGRESS_FILE = ".agent/plan/PROGRESS.md" -- 9
local DEFAULT_PLAN_DOCUMENT = "# 开发方案\n\n## 目标\n\n## 背景与当前实现\n\n## 范围\n\n### 包含\n\n### 不包含\n\n## 已确认决策\n\n## 待确认问题\n\n无\n\n## 技术方案\n\n## 实施步骤\n\n| ID | 工作项 | 依赖 | 验收条件 |\n| --- | --- | --- | --- |\n\n## 风险与回退方案\n\n## 验证计划\n\n## 变更记录\n"
local DEFAULT_PROGRESS_DOCUMENT = "# 开发进度\n\n## 当前工作\n\n## 步骤进度\n\n| ID | 状态 | 最新结果 | 下一步 |\n| --- | --- | --- | --- |\n\n## 修改记录\n\n## 验证证据\n\n## 阻塞问题\n\n## 进度日志\n"
local function trimText(value) -- 61
	local trimmed = string.match(value, "^%s*(.-)%s*$") -- 62
	return trimmed or "" -- 63
end -- 61
function ____exports.normalizeAgentPath(path) -- 66
	local normalized = table.concat( -- 67
		__TS__StringSplit( -- 67
			trimText(path), -- 67
			"\\" -- 67
		), -- 67
		"/" -- 67
	) -- 67
	while __TS__StringStartsWith(normalized, "./") do -- 67
		normalized = string.sub(normalized, 3) -- 68
	end -- 68
	return normalized -- 69
end -- 66
function ____exports.isMainAgentMemoryPath(path) -- 72
	local normalized = ____exports.normalizeAgentPath(path) -- 73
	return normalized == ".agent/main" or __TS__StringStartsWith(normalized, ".agent/main/") -- 74
end -- 72
function ____exports.isAgentPlanPath(path) -- 77
	local normalized = ____exports.normalizeAgentPath(path) -- 78
	return normalized == ____exports.AGENT_PLAN_DIR or __TS__StringStartsWith(normalized, ____exports.AGENT_PLAN_DIR .. "/") -- 79
end -- 77
function ____exports.isAgentInternalDocumentPath(path) -- 82
	return ____exports.isMainAgentMemoryPath(path) or ____exports.isAgentPlanPath(path) -- 83
end -- 82
local function ensureDirectory(dir) -- 86
	if Content:exist(dir) then -- 86
		return Content:isdir(dir) -- 87
	end -- 87
	local parent = Path:getPath(dir) -- 88
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirectory(parent) then -- 88
		return false -- 89
	end -- 89
	return Content:mkdir(dir) -- 90
end -- 86
function ____exports.ensureAgentPlanDocuments(workDir) -- 93
	local dir = Path(workDir, ____exports.AGENT_PLAN_DIR) -- 94
	if not ensureDirectory(dir) then -- 94
		return {success = false, message = "failed to create " .. ____exports.AGENT_PLAN_DIR} -- 95
	end -- 95
	local created = {} -- 96
	local documents = {{____exports.AGENT_PLAN_FILE, DEFAULT_PLAN_DOCUMENT}, {____exports.AGENT_PROGRESS_FILE, DEFAULT_PROGRESS_DOCUMENT}} -- 97
	do -- 97
		local i = 0 -- 101
		while i < #documents do -- 101
			do -- 101
				local relative, content = table.unpack(documents[i + 1], 1, 2) -- 102
				local path = Path(workDir, relative) -- 103
				if Content:exist(path) then -- 103
					goto __continue14 -- 104
				end -- 104
				if not Content:save(path, content) then -- 104
					return {success = false, message = "failed to create " .. relative} -- 105
				end -- 105
				Tools.sendWebIDEFileUpdate(path, true, content) -- 106
				created[#created + 1] = relative -- 107
			end -- 107
			::__continue14:: -- 107
			i = i + 1 -- 101
		end -- 101
	end -- 101
	return {success = true, created = created} -- 109
end -- 93
function ____exports.isEditBudgetExhausted(state) -- 120
	local mustCreateFreshEntry = state.freshProjectBuildPending == true and state.freshProjectCodeFile == nil and state.hasBuilt ~= true -- 121
	return state.unbuiltEdits == true and (state.editsSinceBuild or 0) >= 3 and not mustCreateFreshEntry -- 124
end -- 120
function ____exports.getUncoveredConversationMessages(messages, lastConsolidatedIndex) -- 129
	return __TS__ArraySlice(messages, lastConsolidatedIndex) -- 130
end -- 129
function ____exports.normalizeLineEndings(text) -- 133
	return table.concat( -- 134
		__TS__StringSplit( -- 134
			table.concat( -- 134
				__TS__StringSplit(text, "\r\n"), -- 134
				"\n" -- 134
			), -- 134
			"\r" -- 134
		), -- 134
		"\n" -- 134
	) -- 134
end -- 133
function ____exports.countOccurrences(text, needle) -- 137
	if needle == "" then -- 137
		return 0 -- 138
	end -- 138
	local count = 0 -- 139
	local start = 0 -- 140
	while start <= #text - #needle do -- 140
		local index = (string.find( -- 142
			text, -- 142
			needle, -- 142
			math.max(start + 1, 1), -- 142
			true -- 142
		) or 0) - 1 -- 142
		if index < 0 then -- 142
			break -- 143
		end -- 143
		count = count + 1 -- 144
		start = index + #needle -- 145
	end -- 145
	return count -- 147
end -- 137
function ____exports.containsWholeFileDuplicate(existing, replacement) -- 150
	local normalizedExisting = ____exports.normalizeLineEndings(existing) -- 151
	local normalizedReplacement = ____exports.normalizeLineEndings(replacement) -- 152
	if #normalizedExisting < 16 or #normalizedReplacement <= #normalizedExisting then -- 152
		return false -- 153
	end -- 153
	return ____exports.countOccurrences(normalizedReplacement, normalizedExisting) > 1 -- 154
end -- 150
function ____exports.successfulEditResult(workDir, path, base) -- 157
	local current = Tools.readFileRaw(workDir, path) -- 162
	local currentCharacters = current.success and type(current.content) == "string" and #current.content or 0 -- 163
	return __TS__ObjectAssign( -- 164
		{}, -- 164
		base, -- 165
		{ -- 164
			actualSaved = current.success, -- 166
			actualSavedCharacters = currentCharacters, -- 167
			currentFileExists = current.success, -- 168
			currentCharacters = currentCharacters, -- 169
			currentState = current.success and (("saved " .. tostring(currentCharacters)) .. " characters to ") .. path or "file state unavailable after edit: " .. sanitizeUTF8(current.message) -- 170
		} -- 170
	) -- 170
end -- 157
return ____exports -- 157