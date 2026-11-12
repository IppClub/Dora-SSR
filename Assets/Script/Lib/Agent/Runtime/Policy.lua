-- [ts]: Policy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
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
--- Documentation edits do not invalidate a game/source build. Unknown files do.
function ____exports.requiresAgentBuildForPath(path) -- 94
	if ____exports.isAgentInternalDocumentPath(path) then -- 94
		return false -- 95
	end -- 95
	local normalized = string.lower(____exports.normalizeAgentPath(path)) -- 96
	local ext = Path:getExt(normalized) -- 97
	if __TS__ArrayIndexOf({ -- 97
		"md", -- 98
		"markdown", -- 98
		"rst", -- 98
		"adoc", -- 98
		"asciidoc" -- 98
	}, ext) >= 0 then -- 98
		return false -- 98
	end -- 98
	local name = Path:getFilename(normalized) -- 99
	local stem = __TS__StringEndsWith(name, ".txt") and string.sub(name, 1, -5) or name -- 100
	return __TS__ArrayIndexOf({ -- 101
		"readme", -- 101
		"license", -- 101
		"licence", -- 101
		"notice", -- 101
		"changelog", -- 101
		"changes", -- 101
		"copying", -- 101
		"authors", -- 101
		"contributing" -- 101
	}, stem) < 0 -- 101
end -- 94
local function ensureDirectory(dir) -- 104
	if Content:exist(dir) then -- 104
		return Content:isdir(dir) -- 105
	end -- 105
	local parent = Path:getPath(dir) -- 106
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirectory(parent) then -- 106
		return false -- 107
	end -- 107
	return Content:mkdir(dir) -- 108
end -- 104
function ____exports.ensureAgentPlanDocuments(workDir) -- 111
	local dir = Path(workDir, ____exports.AGENT_PLAN_DIR) -- 112
	if not ensureDirectory(dir) then -- 112
		return {success = false, message = "failed to create " .. ____exports.AGENT_PLAN_DIR} -- 113
	end -- 113
	local created = {} -- 114
	local documents = {{____exports.AGENT_PLAN_FILE, DEFAULT_PLAN_DOCUMENT}, {____exports.AGENT_PROGRESS_FILE, DEFAULT_PROGRESS_DOCUMENT}} -- 115
	do -- 115
		local i = 0 -- 119
		while i < #documents do -- 119
			do -- 119
				local relative, content = table.unpack(documents[i + 1], 1, 2) -- 120
				local path = Path(workDir, relative) -- 121
				if Content:exist(path) then -- 121
					goto __continue20 -- 122
				end -- 122
				if not Content:save(path, content) then -- 122
					return {success = false, message = "failed to create " .. relative} -- 123
				end -- 123
				sendWebIDEFileUpdate(path, true, content) -- 124
				created[#created + 1] = relative -- 125
			end -- 125
			::__continue20:: -- 125
			i = i + 1 -- 119
		end -- 119
	end -- 119
	return {success = true, created = created} -- 127
end -- 111
function ____exports.isEditBudgetExhausted(state) -- 138
	local mustCreateFreshEntry = state.freshProjectBuildPending == true and state.freshProjectCodeFile == nil and state.hasBuilt ~= true -- 139
	return state.unbuiltEdits == true and (state.editsSinceBuild or 0) >= 3 and not mustCreateFreshEntry -- 142
end -- 138
function ____exports.getUncoveredConversationMessages(messages, lastConsolidatedIndex) -- 147
	return __TS__ArraySlice(messages, lastConsolidatedIndex) -- 148
end -- 147
function ____exports.normalizeLineEndings(text) -- 151
	return table.concat( -- 152
		__TS__StringSplit( -- 152
			table.concat( -- 152
				__TS__StringSplit(text, "\r\n"), -- 152
				"\n" -- 152
			), -- 152
			"\r" -- 152
		), -- 152
		"\n" -- 152
	) -- 152
end -- 151
function ____exports.countOccurrences(text, needle) -- 155
	if needle == "" then -- 155
		return 0 -- 156
	end -- 156
	local count = 0 -- 157
	local start = 0 -- 158
	while start <= #text - #needle do -- 158
		local index = (string.find( -- 160
			text, -- 160
			needle, -- 160
			math.max(start + 1, 1), -- 160
			true -- 160
		) or 0) - 1 -- 160
		if index < 0 then -- 160
			break -- 161
		end -- 161
		count = count + 1 -- 162
		start = index + #needle -- 163
	end -- 163
	return count -- 165
end -- 155
function ____exports.containsWholeFileDuplicate(existing, replacement) -- 168
	local normalizedExisting = ____exports.normalizeLineEndings(existing) -- 169
	local normalizedReplacement = ____exports.normalizeLineEndings(replacement) -- 170
	if #normalizedExisting < 16 or #normalizedReplacement <= #normalizedExisting then -- 170
		return false -- 171
	end -- 171
	return ____exports.countOccurrences(normalizedReplacement, normalizedExisting) > 1 -- 172
end -- 168
function ____exports.successfulEditResult(workDir, path, base) -- 175
	local current = Tools.readFileRaw(workDir, path) -- 180
	local currentCharacters = current.success and type(current.content) == "string" and #current.content or 0 -- 181
	return __TS__ObjectAssign( -- 182
		{}, -- 182
		base, -- 183
		{ -- 182
			actualSaved = current.success, -- 184
			actualSavedCharacters = currentCharacters, -- 185
			currentFileExists = current.success, -- 186
			currentCharacters = currentCharacters, -- 187
			currentState = current.success and (("saved " .. tostring(currentCharacters)) .. " characters to ") .. path or "file state unavailable after edit: " .. sanitizeUTF8(current.message) -- 188
		} -- 188
	) -- 188
end -- 175
return ____exports -- 175