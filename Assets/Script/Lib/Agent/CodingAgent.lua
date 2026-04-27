-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local ____exports = {} -- 1
local stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, SEARCH_DORA_API_LIMIT_MAX -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local callLLMStreamAggregated = ____Utils.callLLMStreamAggregated -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function stripWrappingQuotes(value) -- 44
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 45
	result = string.gsub(result, "^'(.*)'$", "%1") -- 46
	return result -- 47
end -- 47
function parseSimpleYAML(text) -- 97
	if not text or __TS__StringTrim(text) == "" then -- 97
		return nil -- 99
	end -- 99
	local result = {} -- 102
	local lines = __TS__StringSplit(text, "\n") -- 103
	local currentKey = "" -- 104
	local currentArray = nil -- 105
	do -- 105
		local i = 0 -- 107
		while i < #lines do -- 107
			do -- 107
				local line = lines[i + 1] -- 108
				local trimmed = __TS__StringTrim(line) -- 109
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 109
					goto __continue16 -- 112
				end -- 112
				if __TS__StringStartsWith(trimmed, "- ") then -- 112
					if currentArray ~= nil and currentKey ~= "" then -- 112
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 117
						local cleaned = stripWrappingQuotes(value) -- 118
						currentArray[#currentArray + 1] = cleaned -- 119
					end -- 119
					goto __continue16 -- 121
				end -- 121
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 124
				if colonIndex > 0 then -- 124
					if currentArray ~= nil and currentKey ~= "" then -- 124
						result[currentKey] = currentArray -- 127
						currentArray = nil -- 128
					end -- 128
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 131
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 132
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 132
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 135
						local items = __TS__ArrayMap( -- 136
							__TS__StringSplit(arrayText, ","), -- 136
							function(____, item) -- 136
								local cleaned = stripWrappingQuotes(__TS__StringTrim(item)) -- 137
								return cleaned -- 138
							end -- 136
						) -- 136
						result[key] = items -- 140
						goto __continue16 -- 141
					end -- 141
					if value == "true" then -- 141
						result[key] = true -- 145
						goto __continue16 -- 146
					end -- 146
					if value == "false" then -- 146
						result[key] = false -- 149
						goto __continue16 -- 150
					end -- 150
					if value == "" then -- 150
						currentKey = key -- 154
						currentArray = {} -- 155
						if i + 1 < #lines then -- 155
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 157
							if not __TS__StringStartsWith(nextLine, "- ") then -- 157
								currentArray = nil -- 159
								result[key] = "" -- 160
							end -- 160
						else -- 160
							currentArray = nil -- 163
							result[key] = "" -- 164
						end -- 164
						goto __continue16 -- 166
					end -- 166
					local cleaned = stripWrappingQuotes(value) -- 169
					result[key] = cleaned -- 170
					currentKey = "" -- 171
					currentArray = nil -- 172
				end -- 172
			end -- 172
			::__continue16:: -- 172
			i = i + 1 -- 107
		end -- 107
	end -- 107
	if currentArray ~= nil and currentKey ~= "" then -- 107
		result[currentKey] = currentArray -- 177
	end -- 177
	return result -- 180
end -- 180
function emitAgentEvent(shared, event) -- 725
	if shared.onEvent then -- 725
		do -- 725
			local function ____catch(____error) -- 725
				Log( -- 730
					"Error", -- 730
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 730
				) -- 730
			end -- 730
			local ____try, ____hasReturned = pcall(function() -- 730
				shared:onEvent(event) -- 728
			end) -- 728
			if not ____try then -- 728
				____catch(____hasReturned) -- 728
			end -- 728
		end -- 728
	end -- 728
end -- 728
function truncateText(text, maxLen) -- 974
	if #text <= maxLen then -- 974
		return text -- 975
	end -- 975
	local nextPos = utf8.offset(text, maxLen + 1) -- 976
	if nextPos == nil then -- 976
		return text -- 977
	end -- 977
	return string.sub(text, 1, nextPos - 1) .. "..." -- 978
end -- 978
function getReplyLanguageDirective(shared) -- 988
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 989
end -- 989
function replacePromptVars(template, vars) -- 994
	local output = template -- 995
	for key in pairs(vars) do -- 996
		output = table.concat( -- 997
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 997
			vars[key] or "" or "," -- 997
		) -- 997
	end -- 997
	return output -- 999
end -- 999
function getDecisionToolDefinitions(shared) -- 1123
	local base = replacePromptVars( -- 1124
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1125
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1126
	) -- 1126
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1128
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1149
		getAllowedToolsForRole(shared.role), -- 1150
		", " -- 1150
	) or "" -- 1150
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1152
	if (shared and shared.decisionMode) ~= "xml" then -- 1152
		return withRole -- 1154
	end -- 1154
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1156
end -- 1156
function persistHistoryState(shared) -- 1432
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1433
end -- 1433
function getActiveConversationMessages(shared) -- 1440
	local activeMessages = {} -- 1441
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1441
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1448
	end -- 1448
	do -- 1448
		local i = shared.lastConsolidatedIndex -- 1452
		while i < #shared.messages do -- 1452
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1453
			i = i + 1 -- 1452
		end -- 1452
	end -- 1452
	return activeMessages -- 1455
end -- 1455
function getActiveRealMessageCount(shared) -- 1458
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1459
end -- 1459
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1462
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1467
	local previousActiveStart = shared.lastConsolidatedIndex -- 1468
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1469
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1470
	if type(carryMessageIndex) == "number" then -- 1470
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1470
		else -- 1470
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1478
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1481
		end -- 1481
	else -- 1481
		shared.carryMessageIndex = nil -- 1486
	end -- 1486
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1486
		shared.carryMessageIndex = nil -- 1496
	end -- 1496
end -- 1496
function getAllowedToolsForRole(role) -- 1792
	return role == "main" and ({ -- 1793
		"read_file", -- 1794
		"edit_file", -- 1794
		"delete_file", -- 1794
		"grep_files", -- 1794
		"search_dora_api", -- 1794
		"glob_files", -- 1794
		"build", -- 1794
		"list_sub_agents", -- 1794
		"spawn_sub_agent", -- 1794
		"finish" -- 1794
	}) or ({ -- 1794
		"read_file", -- 1795
		"edit_file", -- 1795
		"delete_file", -- 1795
		"grep_files", -- 1795
		"search_dora_api", -- 1795
		"glob_files", -- 1795
		"build", -- 1795
		"finish" -- 1795
	}) -- 1795
end -- 1795
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1901
	if includeToolDefinitions == nil then -- 1901
		includeToolDefinitions = false -- 1901
	end -- 1901
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase, make direct edits when that is the simplest path, and delegate larger or parallelizable implementation work by spawning sub agents.\n\nRules:\n- You may use the full toolset directly, including edit_file, delete_file, and build.\n- Use direct tools for small, focused, or user-interactive changes where staying in the current run gives the clearest result.\n- Use spawn_sub_agent for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 1902
	local sections = { -- 1926
		shared.promptPack.agentIdentityPrompt, -- 1927
		rolePrompt, -- 1928
		getReplyLanguageDirective(shared) -- 1929
	} -- 1929
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1931
	if memoryContext ~= "" then -- 1931
		sections[#sections + 1] = memoryContext -- 1933
	end -- 1933
	if includeToolDefinitions then -- 1933
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1936
		if shared.decisionMode == "xml" then -- 1936
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1938
		end -- 1938
	end -- 1938
	local skillsSection = buildSkillsSection(shared) -- 1942
	if skillsSection ~= "" then -- 1942
		sections[#sections + 1] = skillsSection -- 1944
	end -- 1944
	return table.concat(sections, "\n\n") -- 1946
end -- 1946
function buildSkillsSection(shared) -- 1949
	local ____opt_34 = shared.skills -- 1949
	if not (____opt_34 and ____opt_34.loader) then -- 1949
		return "" -- 1951
	end -- 1951
	return shared.skills.loader:buildSkillsPromptSection() -- 1953
end -- 1953
function buildXmlDecisionInstruction(shared, feedback) -- 2065
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2066
end -- 2066
function emitAgentTaskFinishEvent(shared, success, message) -- 3173
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3174
	emitAgentEvent(shared, { -- 3180
		type = "task_finished", -- 3181
		sessionId = shared.sessionId, -- 3182
		taskId = shared.taskId, -- 3183
		success = result.success, -- 3184
		message = result.message, -- 3185
		steps = result.steps -- 3186
	}) -- 3186
	return result -- 3188
end -- 3188
local function isRecord(value) -- 10
	return type(value) == "table" -- 11
end -- 10
local function isArray(value) -- 14
	return __TS__ArrayIsArray(value) -- 15
end -- 14
local SkillPriority = SkillPriority or ({}) -- 33
SkillPriority.BuiltIn = 0 -- 34
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 34
SkillPriority.User = 1 -- 35
SkillPriority[SkillPriority.User] = "User" -- 35
SkillPriority.Project = 2 -- 36
SkillPriority[SkillPriority.Project] = "Project" -- 36
local function escapeXMLText(text) -- 50
	local result = string.gsub(text, "&", "&amp;") -- 51
	result = string.gsub(result, "<", "&lt;") -- 52
	result = string.gsub(result, ">", "&gt;") -- 53
	result = string.gsub(result, "\"", "&quot;") -- 54
	result = string.gsub(result, "'", "&apos;") -- 55
	return result -- 56
end -- 50
local function parseYAMLFrontmatter(content) -- 59
	if not content or __TS__StringTrim(content) == "" then -- 59
		return {metadata = nil, body = "", error = "empty content"} -- 65
	end -- 65
	local trimmed = __TS__StringTrim(content) -- 68
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 70
	end -- 70
	local lines = __TS__StringSplit(trimmed, "\n") -- 73
	local endLine = -1 -- 74
	do -- 74
		local i = 1 -- 75
		while i < #lines do -- 75
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 77
				break -- 78
			end -- 78
			i = i + 1 -- 75
		end -- 75
	end -- 75
	if endLine < 0 then -- 75
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 83
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 86
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 87
	local metadata = parseSimpleYAML(frontmatterText) -- 89
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 91
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 92
	return {metadata = metadata, body = body} -- 94
end -- 59
local function validateSkillMetadata(metadata) -- 183
	if not metadata then -- 183
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 187
	end -- 187
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 196
	if name == "" then -- 196
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 198
	end -- 198
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 207
	local always = metadata.always == true -- 211
	return {metadata = {name = name, description = description, always = always}} -- 213
end -- 183
local SkillsLoader = __TS__Class() -- 222
SkillsLoader.name = "SkillsLoader" -- 222
function SkillsLoader.prototype.____constructor(self, config) -- 227
	self.skills = __TS__New(Map) -- 224
	self.loaded = false -- 225
	self.config = config -- 228
end -- 227
function SkillsLoader.prototype.load(self) -- 231
	self.skills:clear() -- 232
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 234
	local builtInParent = Content.assetPath -- 235
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 236
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 238
	local userParent = Content.writablePath -- 239
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 240
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 242
	local projectParent = self.config.projectDir -- 243
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 244
	self.loaded = true -- 246
	Log( -- 247
		"Info", -- 247
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 247
	) -- 247
end -- 231
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 250
	if not Content:exist(dir) or not Content:isdir(dir) then -- 250
		return -- 252
	end -- 252
	local subdirs = Content:getDirs(dir) -- 255
	if not subdirs or #subdirs == 0 then -- 255
		return -- 257
	end -- 257
	for ____, subdir in ipairs(subdirs) do -- 260
		do -- 260
			local skillPath = Path(dir, subdir, "SKILL.md") -- 261
			if not Content:exist(skillPath) then -- 261
				goto __continue39 -- 263
			end -- 263
			local skill = self:loadSkillFile(skillPath) -- 266
			if not skill then -- 266
				goto __continue39 -- 268
			end -- 268
			skill.location = Path:getRelative(skillPath, parent) -- 271
			local existing = self.skills:get(skill.name) -- 273
			if existing and existing.priority >= priority then -- 273
				goto __continue39 -- 275
			end -- 275
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 278
		end -- 278
		::__continue39:: -- 278
	end -- 278
end -- 250
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 282
	local content = Content:load(skillPath) -- 283
	if not content then -- 283
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 285
		return nil -- 286
	end -- 286
	local parsed = parseYAMLFrontmatter(content) -- 289
	local validated = validateSkillMetadata(parsed.metadata) -- 290
	if validated.error then -- 290
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 293
		return nil -- 294
	end -- 294
	local displayLocation = skillPath -- 297
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 297
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 299
	end -- 299
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 302
	return skill -- 308
end -- 282
function SkillsLoader.prototype.getAllSkills(self) -- 311
	if not self.loaded then -- 311
		self:load() -- 313
	end -- 313
	local result = {} -- 316
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 317
		result[#result + 1] = entry.skill -- 318
	end -- 318
	__TS__ArraySort( -- 321
		result, -- 321
		function(____, a, b) -- 321
			if a.name < b.name then -- 321
				return -1 -- 323
			end -- 323
			if a.name > b.name then -- 323
				return 1 -- 326
			end -- 326
			if a.location < b.location then -- 326
				return -1 -- 329
			end -- 329
			if a.location > b.location then -- 329
				return 1 -- 332
			end -- 332
			return 0 -- 334
		end -- 321
	) -- 321
	return result -- 337
end -- 311
function SkillsLoader.prototype.getSkill(self, name) -- 340
	if not self.loaded then -- 340
		self:load() -- 342
	end -- 342
	local ____opt_0 = self.skills:get(name) -- 342
	return ____opt_0 and ____opt_0.skill -- 345
end -- 340
function SkillsLoader.prototype.getAlwaysSkills(self) -- 348
	local all = self:getAllSkills() -- 349
	return __TS__ArrayFilter( -- 350
		all, -- 350
		function(____, skill) return skill.always == true end -- 350
	) -- 350
end -- 348
function SkillsLoader.prototype.getSummarySkills(self) -- 353
	local all = self:getAllSkills() -- 354
	return __TS__ArrayFilter( -- 355
		all, -- 355
		function(____, skill) return skill.always ~= true end -- 355
	) -- 355
end -- 353
function SkillsLoader.prototype.buildLevel1Summary(self) -- 358
	local skills = self:getSummarySkills() -- 359
	if #skills == 0 then -- 359
		return "" -- 362
	end -- 362
	local parts = {} -- 365
	for ____, skill in ipairs(skills) do -- 367
		local skillXML = "<skill>\n" -- 368
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 369
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 370
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 371
		skillXML = skillXML .. "</skill>" -- 372
		parts[#parts + 1] = skillXML -- 373
	end -- 373
	return table.concat(parts, "\n\n") -- 376
end -- 358
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 379
	local skills = self:getAlwaysSkills() -- 380
	if #skills == 0 then -- 380
		return "" -- 383
	end -- 383
	local parts = {} -- 386
	for ____, skill in ipairs(skills) do -- 388
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 389
		if skill.description ~= nil then -- 389
			parts[#parts + 1] = skill.description .. "\n" -- 391
		end -- 391
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 391
			parts[#parts + 1] = "\n" .. skill.body -- 394
		end -- 394
		parts[#parts + 1] = "" -- 396
	end -- 396
	return table.concat(parts, "\n") -- 399
end -- 379
function SkillsLoader.prototype.loadSkillContent(self, name) -- 402
	local skill = self:getSkill(name) -- 403
	if not skill then -- 403
		return nil -- 405
	end -- 405
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 405
		return skill.body -- 409
	end -- 409
	local content = Content:load(skill.location) -- 412
	if not content then -- 412
		return nil -- 414
	end -- 414
	local parsed = parseYAMLFrontmatter(content) -- 417
	return parsed.body or nil -- 418
end -- 402
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 421
	if not self.loaded then -- 421
		self:load() -- 423
	end -- 423
	local sections = {} -- 426
	local activeContent = self:buildActiveSkillsContent() -- 428
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 429
	local summary = self:buildLevel1Summary() -- 431
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 432
	return table.concat(sections, "\n\n---\n\n")
end -- 421
function SkillsLoader.prototype.escapeXML(self, text) -- 437
	return escapeXMLText(text) -- 438
end -- 437
function SkillsLoader.prototype.reload(self) -- 441
	self.loaded = false -- 442
	self:load() -- 443
end -- 441
function SkillsLoader.prototype.getSkillCount(self) -- 446
	if not self.loaded then -- 446
		self:load() -- 448
	end -- 448
	return self.skills.size -- 450
end -- 446
local function createSkillsLoader(config) -- 454
	return __TS__New(SkillsLoader, config) -- 455
end -- 454
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 539
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 642
local HISTORY_READ_FILE_MAX_LINES = 300 -- 643
local READ_FILE_DEFAULT_LIMIT = 300 -- 644
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 645
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 646
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 647
SEARCH_DORA_API_LIMIT_MAX = 20 -- 648
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 649
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 650
local SEARCH_PREVIEW_CONTEXT = 80 -- 651
local AGENT_DEFAULT_MAX_STEPS = 100 -- 652
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 653
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 654
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 655
local function buildLLMOptions(llmConfig, overrides) -- 657
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 658
	if llmConfig.reasoningEffort then -- 658
		options.reasoning_effort = llmConfig.reasoningEffort -- 663
	end -- 663
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 665
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 665
		__TS__Delete(merged, "reasoning_effort") -- 670
	else -- 670
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 672
	end -- 672
	return merged -- 674
end -- 657
local function emitAgentStartEvent(shared, action) -- 735
	emitAgentEvent(shared, { -- 736
		type = "tool_started", -- 737
		sessionId = shared.sessionId, -- 738
		taskId = shared.taskId, -- 739
		step = action.step, -- 740
		tool = action.tool -- 741
	}) -- 741
end -- 735
local function emitAgentFinishEvent(shared, action) -- 745
	emitAgentEvent(shared, { -- 746
		type = "tool_finished", -- 747
		sessionId = shared.sessionId, -- 748
		taskId = shared.taskId, -- 749
		step = action.step, -- 750
		tool = action.tool, -- 751
		result = action.result or ({}) -- 752
	}) -- 752
end -- 745
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 756
	emitAgentEvent(shared, { -- 757
		type = "assistant_message_updated", -- 758
		sessionId = shared.sessionId, -- 759
		taskId = shared.taskId, -- 760
		step = shared.step + 1, -- 761
		content = content, -- 762
		reasoningContent = reasoningContent -- 763
	}) -- 763
end -- 756
local function getMemoryCompressionStartReason(shared) -- 767
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 768
end -- 767
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 773
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 774
end -- 773
local function getMemoryCompressionFailureReason(shared, ____error) -- 779
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 780
end -- 779
local function summarizeHistoryEntryPreview(text, maxChars) -- 785
	if maxChars == nil then -- 785
		maxChars = 180 -- 785
	end -- 785
	local trimmed = __TS__StringTrim(text) -- 786
	if trimmed == "" then -- 786
		return "" -- 787
	end -- 787
	return truncateText(trimmed, maxChars) -- 788
end -- 785
local function getCancelledReason(shared) -- 791
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 791
		return shared.stopToken.reason -- 792
	end -- 792
	return shared.useChineseResponse and "已取消" or "cancelled" -- 793
end -- 791
local function getMaxStepsReachedReason(shared) -- 796
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 797
end -- 796
local function getFailureSummaryFallback(shared, ____error) -- 802
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 803
end -- 802
local function finalizeAgentFailure(shared, ____error) -- 808
	if shared.stopToken.stopped then -- 808
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 810
		return emitAgentTaskFinishEvent( -- 811
			shared, -- 811
			false, -- 811
			getCancelledReason(shared) -- 811
		) -- 811
	end -- 811
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 813
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 814
end -- 808
local function getPromptCommand(prompt) -- 817
	local trimmed = __TS__StringTrim(prompt) -- 818
	if trimmed == "/compact" then -- 818
		return "compact" -- 819
	end -- 819
	if trimmed == "/clear" then -- 819
		return "clear" -- 820
	end -- 820
	return nil -- 821
end -- 817
function ____exports.truncateAgentUserPrompt(prompt) -- 824
	if not prompt then -- 824
		return "" -- 825
	end -- 825
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 825
		return prompt -- 826
	end -- 826
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 827
	if offset == nil then -- 827
		return prompt -- 828
	end -- 828
	return string.sub(prompt, 1, offset - 1) -- 829
end -- 824
local function canWriteStepLLMDebug(shared, stepId) -- 832
	if stepId == nil then -- 832
		stepId = shared.step + 1 -- 832
	end -- 832
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 833
end -- 832
local function ensureDirRecursive(dir) -- 840
	if not dir then -- 840
		return false -- 841
	end -- 841
	if Content:exist(dir) then -- 841
		return Content:isdir(dir) -- 842
	end -- 842
	local parent = Path:getPath(dir) -- 843
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 843
		return false -- 845
	end -- 845
	return Content:mkdir(dir) -- 847
end -- 840
local function encodeDebugJSON(value) -- 850
	local text, err = safeJsonEncode(value) -- 851
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 852
end -- 850
local function getStepLLMDebugDir(shared) -- 855
	return Path( -- 856
		shared.workingDir, -- 857
		".agent", -- 858
		tostring(shared.sessionId), -- 859
		tostring(shared.taskId) -- 860
	) -- 860
end -- 855
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 864
	return Path( -- 865
		getStepLLMDebugDir(shared), -- 865
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 865
	) -- 865
end -- 864
local function getLatestStepLLMDebugSeq(shared, stepId) -- 868
	if not canWriteStepLLMDebug(shared, stepId) then -- 868
		return 0 -- 869
	end -- 869
	local dir = getStepLLMDebugDir(shared) -- 870
	if not Content:exist(dir) or not Content:isdir(dir) then -- 870
		return 0 -- 871
	end -- 871
	local latest = 0 -- 872
	for ____, file in ipairs(Content:getFiles(dir)) do -- 873
		do -- 873
			local name = Path:getFilename(file) -- 874
			local seqText = string.match( -- 875
				name, -- 875
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 875
			) -- 875
			if seqText ~= nil then -- 875
				latest = math.max( -- 877
					latest, -- 877
					tonumber(seqText) -- 877
				) -- 877
				goto __continue124 -- 878
			end -- 878
			local legacyMatch = string.match( -- 880
				name, -- 880
				("^" .. tostring(stepId)) .. "_in%.md$" -- 880
			) -- 880
			if legacyMatch ~= nil then -- 880
				latest = math.max(latest, 1) -- 882
			end -- 882
		end -- 882
		::__continue124:: -- 882
	end -- 882
	return latest -- 885
end -- 868
local function writeStepLLMDebugFile(path, content) -- 888
	if not Content:save(path, content) then -- 888
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 890
		return false -- 891
	end -- 891
	return true -- 893
end -- 888
local function createStepLLMDebugPair(shared, stepId, inContent) -- 896
	if not canWriteStepLLMDebug(shared, stepId) then -- 896
		return 0 -- 897
	end -- 897
	local dir = getStepLLMDebugDir(shared) -- 898
	if not ensureDirRecursive(dir) then -- 898
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 900
		return 0 -- 901
	end -- 901
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 903
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 904
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 905
	if not writeStepLLMDebugFile(inPath, inContent) then -- 905
		return 0 -- 907
	end -- 907
	writeStepLLMDebugFile(outPath, "") -- 909
	return seq -- 910
end -- 896
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 913
	if not canWriteStepLLMDebug(shared, stepId) then -- 913
		return -- 914
	end -- 914
	local dir = getStepLLMDebugDir(shared) -- 915
	if not ensureDirRecursive(dir) then -- 915
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 917
		return -- 918
	end -- 918
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 920
	if latestSeq <= 0 then -- 920
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 922
		writeStepLLMDebugFile(outPath, content) -- 923
		return -- 924
	end -- 924
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 926
	writeStepLLMDebugFile(outPath, content) -- 927
end -- 913
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 930
	if not canWriteStepLLMDebug(shared, stepId) then -- 930
		return -- 931
	end -- 931
	local sections = { -- 932
		"# LLM Input", -- 933
		"session_id: " .. tostring(shared.sessionId), -- 934
		"task_id: " .. tostring(shared.taskId), -- 935
		"step_id: " .. tostring(stepId), -- 936
		"phase: " .. phase, -- 937
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 938
		"## Options", -- 939
		"```json", -- 940
		encodeDebugJSON(options), -- 941
		"```" -- 942
	} -- 942
	do -- 942
		local i = 0 -- 944
		while i < #messages do -- 944
			local message = messages[i + 1] -- 945
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 946
			sections[#sections + 1] = encodeDebugJSON(message) -- 947
			i = i + 1 -- 944
		end -- 944
	end -- 944
	createStepLLMDebugPair( -- 949
		shared, -- 949
		stepId, -- 949
		table.concat(sections, "\n") -- 949
	) -- 949
end -- 930
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 952
	if not canWriteStepLLMDebug(shared, stepId) then -- 952
		return -- 953
	end -- 953
	local ____array_2 = __TS__SparseArrayNew( -- 953
		"# LLM Output", -- 955
		"session_id: " .. tostring(shared.sessionId), -- 956
		"task_id: " .. tostring(shared.taskId), -- 957
		"step_id: " .. tostring(stepId), -- 958
		"phase: " .. phase, -- 959
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 960
		table.unpack(meta and ({ -- 961
			"## Meta", -- 961
			"```json", -- 961
			encodeDebugJSON(meta), -- 961
			"```" -- 961
		}) or ({})) -- 961
	) -- 961
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 961
	local sections = {__TS__SparseArraySpread(____array_2)} -- 954
	updateLatestStepLLMDebugOutput( -- 965
		shared, -- 965
		stepId, -- 965
		table.concat(sections, "\n") -- 965
	) -- 965
end -- 952
local function toJson(value) -- 968
	local text, err = safeJsonEncode(value) -- 969
	if text ~= nil then -- 969
		return text -- 970
	end -- 970
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 971
end -- 968
local function utf8TakeHead(text, maxChars) -- 981
	if maxChars <= 0 or text == "" then -- 981
		return "" -- 982
	end -- 982
	local nextPos = utf8.offset(text, maxChars + 1) -- 983
	if nextPos == nil then -- 983
		return text -- 984
	end -- 984
	return string.sub(text, 1, nextPos - 1) -- 985
end -- 981
local function limitReadContentForHistory(content, tool) -- 1002
	local lines = __TS__StringSplit(content, "\n") -- 1003
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1004
	local limitedByLines = overLineLimit and table.concat( -- 1005
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1006
		"\n" -- 1006
	) or content -- 1006
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1006
		return content -- 1009
	end -- 1009
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1011
	local reasons = {} -- 1014
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1014
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1015
	end -- 1015
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1015
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1016
	end -- 1016
	local hint = "Narrow the requested line range." -- 1017
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1018
end -- 1002
local function summarizeEditTextParamForHistory(value, key) -- 1021
	if type(value) ~= "string" then -- 1021
		return nil -- 1022
	end -- 1022
	local text = value -- 1023
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1024
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1025
end -- 1021
local function sanitizeReadResultForHistory(tool, result) -- 1033
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1033
		return result -- 1035
	end -- 1035
	local clone = {} -- 1037
	for key in pairs(result) do -- 1038
		clone[key] = result[key] -- 1039
	end -- 1039
	clone.content = limitReadContentForHistory(result.content, tool) -- 1041
	return clone -- 1042
end -- 1033
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1045
	local shown = math.min(#items, maxItems) -- 1049
	local out = {} -- 1050
	do -- 1050
		local i = 0 -- 1051
		while i < shown do -- 1051
			local row = items[i + 1] -- 1052
			out[#out + 1] = { -- 1053
				file = row.file, -- 1054
				line = row.line, -- 1055
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1056
			} -- 1056
			i = i + 1 -- 1051
		end -- 1051
	end -- 1051
	return out -- 1061
end -- 1045
local function sanitizeSearchResultForHistory(tool, result) -- 1064
	if result.success ~= true or not isArray(result.results) then -- 1064
		return result -- 1068
	end -- 1068
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1068
		return result -- 1069
	end -- 1069
	local clone = {} -- 1070
	for key in pairs(result) do -- 1071
		clone[key] = result[key] -- 1072
	end -- 1072
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1074
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1075
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1075
		local grouped = result.groupedResults -- 1080
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1081
		local sanitizedGroups = {} -- 1082
		do -- 1082
			local i = 0 -- 1083
			while i < shown do -- 1083
				local row = grouped[i + 1] -- 1084
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1085
					file = row.file, -- 1086
					totalMatches = row.totalMatches, -- 1087
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1088
				} -- 1088
				i = i + 1 -- 1083
			end -- 1083
		end -- 1083
		clone.groupedResults = sanitizedGroups -- 1093
	end -- 1093
	return clone -- 1095
end -- 1064
local function sanitizeListFilesResultForHistory(result) -- 1098
	if result.success ~= true or not isArray(result.files) then -- 1098
		return result -- 1099
	end -- 1099
	local clone = {} -- 1100
	for key in pairs(result) do -- 1101
		clone[key] = result[key] -- 1102
	end -- 1102
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1104
	return clone -- 1105
end -- 1098
local function sanitizeActionParamsForHistory(tool, params) -- 1108
	if tool ~= "edit_file" then -- 1108
		return params -- 1109
	end -- 1109
	local clone = {} -- 1110
	for key in pairs(params) do -- 1111
		if key == "old_str" then -- 1111
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1113
		elseif key == "new_str" then -- 1113
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1115
		else -- 1115
			clone[key] = params[key] -- 1117
		end -- 1117
	end -- 1117
	return clone -- 1120
end -- 1108
local function isToolAllowedForRole(role, tool) -- 1165
	return __TS__ArrayIndexOf( -- 1166
		getAllowedToolsForRole(role), -- 1166
		tool -- 1166
	) >= 0 -- 1166
end -- 1165
local function maybeCompressHistory(shared) -- 1169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1169
		local ____shared_9 = shared -- 1170
		local memory = ____shared_9.memory -- 1170
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1171
		local changed = false -- 1172
		do -- 1172
			local round = 0 -- 1173
			while round < maxRounds do -- 1173
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1174
				local activeMessages = getActiveConversationMessages(shared) -- 1175
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1179
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1179
					if changed then -- 1179
						persistHistoryState(shared) -- 1188
					end -- 1188
					return ____awaiter_resolve(nil) -- 1188
				end -- 1188
				local compressionRound = round + 1 -- 1192
				shared.step = shared.step + 1 -- 1193
				local stepId = shared.step -- 1194
				local pendingMessages = #activeMessages -- 1195
				emitAgentEvent( -- 1196
					shared, -- 1196
					{ -- 1196
						type = "memory_compression_started", -- 1197
						sessionId = shared.sessionId, -- 1198
						taskId = shared.taskId, -- 1199
						step = stepId, -- 1200
						tool = "compress_memory", -- 1201
						reason = getMemoryCompressionStartReason(shared), -- 1202
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1203
					} -- 1203
				) -- 1203
				local result = __TS__Await(memory.compressor:compress( -- 1209
					activeMessages, -- 1210
					shared.llmOptions, -- 1211
					shared.llmMaxTry, -- 1212
					shared.decisionMode, -- 1213
					{ -- 1214
						onInput = function(____, phase, messages, options) -- 1215
							saveStepLLMDebugInput( -- 1216
								shared, -- 1216
								stepId, -- 1216
								phase, -- 1216
								messages, -- 1216
								options -- 1216
							) -- 1216
						end, -- 1215
						onOutput = function(____, phase, text, meta) -- 1218
							saveStepLLMDebugOutput( -- 1219
								shared, -- 1219
								stepId, -- 1219
								phase, -- 1219
								text, -- 1219
								meta -- 1219
							) -- 1219
						end -- 1218
					}, -- 1218
					"default", -- 1222
					systemPrompt, -- 1223
					toolDefinitions -- 1224
				)) -- 1224
				if not (result and result.success and result.compressedCount > 0) then -- 1224
					emitAgentEvent( -- 1227
						shared, -- 1227
						{ -- 1227
							type = "memory_compression_finished", -- 1228
							sessionId = shared.sessionId, -- 1229
							taskId = shared.taskId, -- 1230
							step = stepId, -- 1231
							tool = "compress_memory", -- 1232
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1233
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1237
						} -- 1237
					) -- 1237
					if changed then -- 1237
						persistHistoryState(shared) -- 1245
					end -- 1245
					return ____awaiter_resolve(nil) -- 1245
				end -- 1245
				local effectiveCompressedCount = math.max( -- 1249
					0, -- 1250
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1251
				) -- 1251
				if effectiveCompressedCount <= 0 then -- 1251
					if changed then -- 1251
						persistHistoryState(shared) -- 1255
					end -- 1255
					return ____awaiter_resolve(nil) -- 1255
				end -- 1255
				emitAgentEvent( -- 1259
					shared, -- 1259
					{ -- 1259
						type = "memory_compression_finished", -- 1260
						sessionId = shared.sessionId, -- 1261
						taskId = shared.taskId, -- 1262
						step = stepId, -- 1263
						tool = "compress_memory", -- 1264
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1265
						result = { -- 1266
							success = true, -- 1267
							round = compressionRound, -- 1268
							compressedCount = effectiveCompressedCount, -- 1269
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1270
						} -- 1270
					} -- 1270
				) -- 1270
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1273
				changed = true -- 1274
				Log( -- 1275
					"Info", -- 1275
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1275
				) -- 1275
				round = round + 1 -- 1173
			end -- 1173
		end -- 1173
		if changed then -- 1173
			persistHistoryState(shared) -- 1278
		end -- 1278
	end) -- 1278
end -- 1169
local function compactAllHistory(shared) -- 1282
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1282
		local ____shared_16 = shared -- 1283
		local memory = ____shared_16.memory -- 1283
		local rounds = 0 -- 1284
		local totalCompressed = 0 -- 1285
		while getActiveRealMessageCount(shared) > 0 do -- 1285
			if shared.stopToken.stopped then -- 1285
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1288
				return ____awaiter_resolve( -- 1288
					nil, -- 1288
					emitAgentTaskFinishEvent( -- 1289
						shared, -- 1289
						false, -- 1289
						getCancelledReason(shared) -- 1289
					) -- 1289
				) -- 1289
			end -- 1289
			rounds = rounds + 1 -- 1291
			shared.step = shared.step + 1 -- 1292
			local stepId = shared.step -- 1293
			local activeMessages = getActiveConversationMessages(shared) -- 1294
			local pendingMessages = #activeMessages -- 1295
			emitAgentEvent( -- 1296
				shared, -- 1296
				{ -- 1296
					type = "memory_compression_started", -- 1297
					sessionId = shared.sessionId, -- 1298
					taskId = shared.taskId, -- 1299
					step = stepId, -- 1300
					tool = "compress_memory", -- 1301
					reason = getMemoryCompressionStartReason(shared), -- 1302
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1303
				} -- 1303
			) -- 1303
			local result = __TS__Await(memory.compressor:compress( -- 1310
				activeMessages, -- 1311
				shared.llmOptions, -- 1312
				shared.llmMaxTry, -- 1313
				shared.decisionMode, -- 1314
				{ -- 1315
					onInput = function(____, phase, messages, options) -- 1316
						saveStepLLMDebugInput( -- 1317
							shared, -- 1317
							stepId, -- 1317
							phase, -- 1317
							messages, -- 1317
							options -- 1317
						) -- 1317
					end, -- 1316
					onOutput = function(____, phase, text, meta) -- 1319
						saveStepLLMDebugOutput( -- 1320
							shared, -- 1320
							stepId, -- 1320
							phase, -- 1320
							text, -- 1320
							meta -- 1320
						) -- 1320
					end -- 1319
				}, -- 1319
				"budget_max" -- 1323
			)) -- 1323
			if not (result and result.success and result.compressedCount > 0) then -- 1323
				emitAgentEvent( -- 1326
					shared, -- 1326
					{ -- 1326
						type = "memory_compression_finished", -- 1327
						sessionId = shared.sessionId, -- 1328
						taskId = shared.taskId, -- 1329
						step = stepId, -- 1330
						tool = "compress_memory", -- 1331
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1332
						result = { -- 1336
							success = false, -- 1337
							rounds = rounds, -- 1338
							error = result and result.error or "compression returned no changes", -- 1339
							compressedCount = result and result.compressedCount or 0, -- 1340
							fullCompaction = true -- 1341
						} -- 1341
					} -- 1341
				) -- 1341
				return ____awaiter_resolve( -- 1341
					nil, -- 1341
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1344
				) -- 1344
			end -- 1344
			local effectiveCompressedCount = math.max( -- 1349
				0, -- 1350
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1351
			) -- 1351
			if effectiveCompressedCount <= 0 then -- 1351
				return ____awaiter_resolve( -- 1351
					nil, -- 1351
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1354
				) -- 1354
			end -- 1354
			emitAgentEvent( -- 1361
				shared, -- 1361
				{ -- 1361
					type = "memory_compression_finished", -- 1362
					sessionId = shared.sessionId, -- 1363
					taskId = shared.taskId, -- 1364
					step = stepId, -- 1365
					tool = "compress_memory", -- 1366
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1367
					result = { -- 1368
						success = true, -- 1369
						round = rounds, -- 1370
						compressedCount = effectiveCompressedCount, -- 1371
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1372
						fullCompaction = true -- 1373
					} -- 1373
				} -- 1373
			) -- 1373
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1376
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1377
			persistHistoryState(shared) -- 1378
			Log( -- 1379
				"Info", -- 1379
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1379
			) -- 1379
		end -- 1379
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1381
		return ____awaiter_resolve( -- 1381
			nil, -- 1381
			emitAgentTaskFinishEvent( -- 1382
				shared, -- 1383
				true, -- 1384
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1385
			) -- 1385
		) -- 1385
	end) -- 1385
end -- 1282
local function clearSessionHistory(shared) -- 1391
	shared.messages = {} -- 1392
	shared.lastConsolidatedIndex = 0 -- 1393
	shared.carryMessageIndex = nil -- 1394
	persistHistoryState(shared) -- 1395
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1396
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1397
end -- 1391
local function isKnownToolName(name) -- 1406
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1407
end -- 1406
local function getFinishMessage(params, fallback) -- 1419
	if fallback == nil then -- 1419
		fallback = "" -- 1419
	end -- 1419
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1419
		return __TS__StringTrim(params.message) -- 1421
	end -- 1421
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1421
		return __TS__StringTrim(params.response) -- 1424
	end -- 1424
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1424
		return __TS__StringTrim(params.summary) -- 1427
	end -- 1427
	return __TS__StringTrim(fallback) -- 1429
end -- 1419
local function appendConversationMessage(shared, message) -- 1500
	local ____shared_messages_25 = shared.messages -- 1500
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1501
		{}, -- 1501
		message, -- 1502
		{ -- 1501
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1503
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1504
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1505
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1506
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1507
		} -- 1507
	) -- 1507
end -- 1500
local function ensureToolCallId(toolCallId) -- 1511
	if toolCallId and toolCallId ~= "" then -- 1511
		return toolCallId -- 1512
	end -- 1512
	return createLocalToolCallId() -- 1513
end -- 1511
local function appendToolResultMessage(shared, action) -- 1516
	appendConversationMessage( -- 1517
		shared, -- 1517
		{ -- 1517
			role = "tool", -- 1518
			tool_call_id = action.toolCallId, -- 1519
			name = action.tool, -- 1520
			content = action.result and toJson(action.result) or "" -- 1521
		} -- 1521
	) -- 1521
end -- 1516
local function parseXMLToolCallObjectFromText(text) -- 1525
	local children = parseXMLObjectFromText(text, "tool_call") -- 1526
	if not children.success then -- 1526
		return children -- 1527
	end -- 1527
	local rawObj = children.obj -- 1528
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1529
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1530
	if not params.success then -- 1530
		return {success = false, message = params.message} -- 1534
	end -- 1534
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1536
end -- 1525
local function llm(shared, messages, phase) -- 1556
	if phase == nil then -- 1556
		phase = "decision_xml" -- 1559
	end -- 1559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1559
		local stepId = shared.step + 1 -- 1561
		saveStepLLMDebugInput( -- 1562
			shared, -- 1562
			stepId, -- 1562
			phase, -- 1562
			messages, -- 1562
			shared.llmOptions -- 1562
		) -- 1562
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1563
		if res.success then -- 1563
			local ____opt_28 = res.response.choices -- 1563
			local ____opt_26 = ____opt_28 and ____opt_28[1] -- 1563
			local message = ____opt_26 and ____opt_26.message -- 1565
			local text = message and message.content -- 1566
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1567
			if text then -- 1567
				saveStepLLMDebugOutput( -- 1571
					shared, -- 1571
					stepId, -- 1571
					phase, -- 1571
					text, -- 1571
					{success = true} -- 1571
				) -- 1571
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1571
			else -- 1571
				saveStepLLMDebugOutput( -- 1574
					shared, -- 1574
					stepId, -- 1574
					phase, -- 1574
					"empty LLM response", -- 1574
					{success = false} -- 1574
				) -- 1574
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1574
			end -- 1574
		else -- 1574
			saveStepLLMDebugOutput( -- 1578
				shared, -- 1578
				stepId, -- 1578
				phase, -- 1578
				res.raw or res.message, -- 1578
				{success = false} -- 1578
			) -- 1578
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1578
		end -- 1578
	end) -- 1578
end -- 1556
local function parseDecisionObject(rawObj) -- 1595
	if type(rawObj.tool) ~= "string" then -- 1595
		return {success = false, message = "missing tool"} -- 1596
	end -- 1596
	local tool = rawObj.tool -- 1597
	if not isKnownToolName(tool) then -- 1597
		return {success = false, message = "unknown tool: " .. tool} -- 1599
	end -- 1599
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1601
	if tool ~= "finish" and (not reason or reason == "") then -- 1601
		return {success = false, message = tool .. " requires top-level reason"} -- 1605
	end -- 1605
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1607
	return {success = true, tool = tool, params = params, reason = reason} -- 1608
end -- 1595
local function parseDecisionToolCall(functionName, rawObj) -- 1616
	if not isKnownToolName(functionName) then -- 1616
		return {success = false, message = "unknown tool: " .. functionName} -- 1618
	end -- 1618
	if rawObj == nil or rawObj == nil then -- 1618
		return {success = true, tool = functionName, params = {}} -- 1621
	end -- 1621
	if not isRecord(rawObj) then -- 1621
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1624
	end -- 1624
	return {success = true, tool = functionName, params = rawObj} -- 1626
end -- 1616
local function getDecisionPath(params) -- 1633
	if type(params.path) == "string" then -- 1633
		return __TS__StringTrim(params.path) -- 1634
	end -- 1634
	if type(params.target_file) == "string" then -- 1634
		return __TS__StringTrim(params.target_file) -- 1635
	end -- 1635
	return "" -- 1636
end -- 1633
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1639
	local num = __TS__Number(value) -- 1640
	if not __TS__NumberIsFinite(num) then -- 1640
		num = fallback -- 1641
	end -- 1641
	num = math.floor(num) -- 1642
	if num < minValue then -- 1642
		num = minValue -- 1643
	end -- 1643
	if maxValue ~= nil and num > maxValue then -- 1643
		num = maxValue -- 1644
	end -- 1644
	return num -- 1645
end -- 1639
local function parseReadLineParam(value, fallback, paramName) -- 1648
	local num = __TS__Number(value) -- 1653
	if not __TS__NumberIsFinite(num) then -- 1653
		num = fallback -- 1654
	end -- 1654
	num = math.floor(num) -- 1655
	if num == 0 then -- 1655
		return {success = false, message = paramName .. " cannot be 0"} -- 1657
	end -- 1657
	return {success = true, value = num} -- 1659
end -- 1648
local function validateDecision(tool, params) -- 1662
	if tool == "finish" then -- 1662
		local message = getFinishMessage(params) -- 1667
		if message == "" then -- 1667
			return {success = false, message = "finish requires params.message"} -- 1668
		end -- 1668
		params.message = message -- 1669
		return {success = true, params = params} -- 1670
	end -- 1670
	if tool == "read_file" then -- 1670
		local path = getDecisionPath(params) -- 1674
		if path == "" then -- 1674
			return {success = false, message = "read_file requires path"} -- 1675
		end -- 1675
		params.path = path -- 1676
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1677
		if not startLineRes.success then -- 1677
			return startLineRes -- 1678
		end -- 1678
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1679
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1680
		if not endLineRes.success then -- 1680
			return endLineRes -- 1681
		end -- 1681
		params.startLine = startLineRes.value -- 1682
		params.endLine = endLineRes.value -- 1683
		return {success = true, params = params} -- 1684
	end -- 1684
	if tool == "edit_file" then -- 1684
		local path = getDecisionPath(params) -- 1688
		if path == "" then -- 1688
			return {success = false, message = "edit_file requires path"} -- 1689
		end -- 1689
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1690
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1691
		params.path = path -- 1692
		params.old_str = oldStr -- 1693
		params.new_str = newStr -- 1694
		return {success = true, params = params} -- 1695
	end -- 1695
	if tool == "delete_file" then -- 1695
		local targetFile = getDecisionPath(params) -- 1699
		if targetFile == "" then -- 1699
			return {success = false, message = "delete_file requires target_file"} -- 1700
		end -- 1700
		params.target_file = targetFile -- 1701
		return {success = true, params = params} -- 1702
	end -- 1702
	if tool == "grep_files" then -- 1702
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1706
		if pattern == "" then -- 1706
			return {success = false, message = "grep_files requires pattern"} -- 1707
		end -- 1707
		params.pattern = pattern -- 1708
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1709
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1710
		return {success = true, params = params} -- 1711
	end -- 1711
	if tool == "search_dora_api" then -- 1711
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1715
		if pattern == "" then -- 1715
			return {success = false, message = "search_dora_api requires pattern"} -- 1716
		end -- 1716
		params.pattern = pattern -- 1717
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1718
		return {success = true, params = params} -- 1719
	end -- 1719
	if tool == "glob_files" then -- 1719
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1723
		return {success = true, params = params} -- 1724
	end -- 1724
	if tool == "build" then -- 1724
		local path = getDecisionPath(params) -- 1728
		if path ~= "" then -- 1728
			params.path = path -- 1730
		end -- 1730
		return {success = true, params = params} -- 1732
	end -- 1732
	if tool == "list_sub_agents" then -- 1732
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1736
		if status ~= "" then -- 1736
			params.status = status -- 1738
		end -- 1738
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1740
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1741
		if type(params.query) == "string" then -- 1741
			params.query = __TS__StringTrim(params.query) -- 1743
		end -- 1743
		return {success = true, params = params} -- 1745
	end -- 1745
	if tool == "spawn_sub_agent" then -- 1745
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1749
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1750
		if prompt == "" then -- 1750
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1751
		end -- 1751
		if title == "" then -- 1751
			return {success = false, message = "spawn_sub_agent requires title"} -- 1752
		end -- 1752
		params.prompt = prompt -- 1753
		params.title = title -- 1754
		if type(params.expectedOutput) == "string" then -- 1754
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1756
		end -- 1756
		if isArray(params.filesHint) then -- 1756
			params.filesHint = __TS__ArrayMap( -- 1759
				__TS__ArrayFilter( -- 1759
					params.filesHint, -- 1759
					function(____, item) return type(item) == "string" end -- 1760
				), -- 1760
				function(____, item) return sanitizeUTF8(item) end -- 1761
			) -- 1761
		end -- 1761
		return {success = true, params = params} -- 1763
	end -- 1763
	return {success = true, params = params} -- 1766
end -- 1662
local function createFunctionToolSchema(name, description, properties, required) -- 1769
	if required == nil then -- 1769
		required = {} -- 1773
	end -- 1773
	local parameters = {type = "object", properties = properties} -- 1775
	if #required > 0 then -- 1775
		parameters.required = required -- 1780
	end -- 1780
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1782
end -- 1769
local function buildDecisionToolSchema(shared) -- 1798
	local allowed = getAllowedToolsForRole(shared.role) -- 1799
	local tools = { -- 1800
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1801
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1811
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1821
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1829
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1833
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1834
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1835
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1836
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1837
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1838
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1839
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1840
		}, {"pattern"}), -- 1840
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1844
		createFunctionToolSchema( -- 1853
			"search_dora_api", -- 1854
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1854
			{ -- 1856
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1857
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1858
				programmingLanguage = {type = "string", enum = { -- 1859
					"ts", -- 1861
					"tsx", -- 1861
					"lua", -- 1861
					"yue", -- 1861
					"teal", -- 1861
					"tl", -- 1861
					"wa" -- 1861
				}, description = "Preferred language variant to search."}, -- 1861
				limit = { -- 1864
					type = "number", -- 1864
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1864
				}, -- 1864
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1865
			}, -- 1865
			{"pattern"} -- 1867
		), -- 1867
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1869
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 1876
			"active_or_recent", -- 1880
			"running", -- 1880
			"done", -- 1880
			"failed", -- 1880
			"all" -- 1880
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 1880
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1886
	} -- 1886
	return __TS__ArrayFilter( -- 1898
		tools, -- 1898
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1898
	) -- 1898
end -- 1798
local function sanitizeMessagesForLLMInput(messages) -- 1956
	local sanitized = {} -- 1957
	local droppedAssistantToolCalls = 0 -- 1958
	local droppedToolResults = 0 -- 1959
	do -- 1959
		local i = 0 -- 1960
		while i < #messages do -- 1960
			do -- 1960
				local message = messages[i + 1] -- 1961
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1961
					local requiredIds = {} -- 1963
					do -- 1963
						local j = 0 -- 1964
						while j < #message.tool_calls do -- 1964
							local toolCall = message.tool_calls[j + 1] -- 1965
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1966
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1966
								requiredIds[#requiredIds + 1] = id -- 1968
							end -- 1968
							j = j + 1 -- 1964
						end -- 1964
					end -- 1964
					if #requiredIds == 0 then -- 1964
						sanitized[#sanitized + 1] = message -- 1972
						goto __continue300 -- 1973
					end -- 1973
					local matchedIds = {} -- 1975
					local matchedTools = {} -- 1976
					local j = i + 1 -- 1977
					while j < #messages do -- 1977
						local toolMessage = messages[j + 1] -- 1979
						if toolMessage.role ~= "tool" then -- 1979
							break -- 1980
						end -- 1980
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1981
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1981
							matchedIds[toolCallId] = true -- 1983
							matchedTools[#matchedTools + 1] = toolMessage -- 1984
						else -- 1984
							droppedToolResults = droppedToolResults + 1 -- 1986
						end -- 1986
						j = j + 1 -- 1988
					end -- 1988
					local complete = true -- 1990
					do -- 1990
						local j = 0 -- 1991
						while j < #requiredIds do -- 1991
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1991
								complete = false -- 1993
								break -- 1994
							end -- 1994
							j = j + 1 -- 1991
						end -- 1991
					end -- 1991
					if complete then -- 1991
						__TS__ArrayPush( -- 1998
							sanitized, -- 1998
							message, -- 1998
							table.unpack(matchedTools) -- 1998
						) -- 1998
					else -- 1998
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2000
						droppedToolResults = droppedToolResults + #matchedTools -- 2001
					end -- 2001
					i = j - 1 -- 2003
					goto __continue300 -- 2004
				end -- 2004
				if message.role == "tool" then -- 2004
					droppedToolResults = droppedToolResults + 1 -- 2007
					goto __continue300 -- 2008
				end -- 2008
				sanitized[#sanitized + 1] = message -- 2010
			end -- 2010
			::__continue300:: -- 2010
			i = i + 1 -- 1960
		end -- 1960
	end -- 1960
	return sanitized -- 2012
end -- 1956
local function getUnconsolidatedMessages(shared) -- 2015
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2016
end -- 2015
local function getFinalDecisionTurnPrompt(shared) -- 2019
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2020
end -- 2019
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2025
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2025
		return messages -- 2026
	end -- 2026
	local next = __TS__ArrayMap( -- 2027
		messages, -- 2027
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2027
	) -- 2027
	do -- 2027
		local i = #next - 1 -- 2028
		while i >= 0 do -- 2028
			do -- 2028
				local message = next[i + 1] -- 2029
				if message.role ~= "assistant" and message.role ~= "user" then -- 2029
					goto __continue322 -- 2030
				end -- 2030
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2031
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2032
				return next -- 2035
			end -- 2035
			::__continue322:: -- 2035
			i = i - 1 -- 2028
		end -- 2028
	end -- 2028
	next[#next + 1] = {role = "user", content = prompt} -- 2037
	return next -- 2038
end -- 2025
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2041
	if attempt == nil then -- 2041
		attempt = 1 -- 2041
	end -- 2041
	local messages = { -- 2042
		{ -- 2043
			role = "system", -- 2043
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2043
		}, -- 2043
		table.unpack(getUnconsolidatedMessages(shared)) -- 2044
	} -- 2044
	if shared.step + 1 >= shared.maxSteps then -- 2044
		messages = appendPromptToLatestDecisionMessage( -- 2047
			messages, -- 2047
			getFinalDecisionTurnPrompt(shared) -- 2047
		) -- 2047
	end -- 2047
	if lastError and lastError ~= "" then -- 2047
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2050
		messages[#messages + 1] = { -- 2053
			role = "user", -- 2054
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2055
		} -- 2055
	end -- 2055
	return messages -- 2062
end -- 2041
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2069
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2076
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2077
	local repairPrompt = replacePromptVars( -- 2085
		shared.promptPack.xmlDecisionRepairPrompt, -- 2085
		{ -- 2085
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2086
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2087
			CANDIDATE_SECTION = candidateSection, -- 2088
			LAST_ERROR = lastError, -- 2089
			ATTEMPT = tostring(attempt) -- 2090
		} -- 2090
	) -- 2090
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2092
end -- 2069
local function tryParseAndValidateDecision(rawText) -- 2104
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2105
	if not parsed.success then -- 2105
		return {success = false, message = parsed.message, raw = rawText} -- 2107
	end -- 2107
	local decision = parseDecisionObject(parsed.obj) -- 2109
	if not decision.success then -- 2109
		return {success = false, message = decision.message, raw = rawText} -- 2111
	end -- 2111
	local validation = validateDecision(decision.tool, decision.params) -- 2113
	if not validation.success then -- 2113
		return {success = false, message = validation.message, raw = rawText} -- 2115
	end -- 2115
	decision.params = validation.params -- 2117
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2118
	return decision -- 2119
end -- 2104
local function normalizeLineEndings(text) -- 2122
	local res = string.gsub(text, "\r\n", "\n") -- 2123
	res = string.gsub(res, "\r", "\n") -- 2124
	return res -- 2125
end -- 2122
local function countOccurrences(text, searchStr) -- 2128
	if searchStr == "" then -- 2128
		return 0 -- 2129
	end -- 2129
	local count = 0 -- 2130
	local pos = 0 -- 2131
	while true do -- 2131
		local idx = (string.find( -- 2133
			text, -- 2133
			searchStr, -- 2133
			math.max(pos + 1, 1), -- 2133
			true -- 2133
		) or 0) - 1 -- 2133
		if idx < 0 then -- 2133
			break -- 2134
		end -- 2134
		count = count + 1 -- 2135
		pos = idx + #searchStr -- 2136
	end -- 2136
	return count -- 2138
end -- 2128
local function replaceFirst(text, oldStr, newStr) -- 2141
	if oldStr == "" then -- 2141
		return text -- 2142
	end -- 2142
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2143
	if idx < 0 then -- 2143
		return text -- 2144
	end -- 2144
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2145
end -- 2141
local function splitLines(text) -- 2148
	return __TS__StringSplit(text, "\n") -- 2149
end -- 2148
local function getLeadingWhitespace(text) -- 2152
	local i = 0 -- 2153
	while i < #text do -- 2153
		local ch = __TS__StringAccess(text, i) -- 2155
		if ch ~= " " and ch ~= "\t" then -- 2155
			break -- 2156
		end -- 2156
		i = i + 1 -- 2157
	end -- 2157
	return __TS__StringSubstring(text, 0, i) -- 2159
end -- 2152
local function getCommonIndentPrefix(lines) -- 2162
	local common -- 2163
	do -- 2163
		local i = 0 -- 2164
		while i < #lines do -- 2164
			do -- 2164
				local line = lines[i + 1] -- 2165
				if __TS__StringTrim(line) == "" then -- 2165
					goto __continue347 -- 2166
				end -- 2166
				local indent = getLeadingWhitespace(line) -- 2167
				if common == nil then -- 2167
					common = indent -- 2169
					goto __continue347 -- 2170
				end -- 2170
				local j = 0 -- 2172
				local maxLen = math.min(#common, #indent) -- 2173
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2173
					j = j + 1 -- 2175
				end -- 2175
				common = __TS__StringSubstring(common, 0, j) -- 2177
				if common == "" then -- 2177
					break -- 2178
				end -- 2178
			end -- 2178
			::__continue347:: -- 2178
			i = i + 1 -- 2164
		end -- 2164
	end -- 2164
	return common or "" -- 2180
end -- 2162
local function removeIndentPrefix(line, indent) -- 2183
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2183
		return __TS__StringSubstring(line, #indent) -- 2185
	end -- 2185
	local lineIndent = getLeadingWhitespace(line) -- 2187
	local j = 0 -- 2188
	local maxLen = math.min(#lineIndent, #indent) -- 2189
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2189
		j = j + 1 -- 2191
	end -- 2191
	return __TS__StringSubstring(line, j) -- 2193
end -- 2183
local function dedentLines(lines) -- 2196
	local indent = getCommonIndentPrefix(lines) -- 2197
	return { -- 2198
		indent = indent, -- 2199
		lines = __TS__ArrayMap( -- 2200
			lines, -- 2200
			function(____, line) return removeIndentPrefix(line, indent) end -- 2200
		) -- 2200
	} -- 2200
end -- 2196
local function joinLines(lines) -- 2204
	return table.concat(lines, "\n") -- 2205
end -- 2204
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2208
	local contentLines = splitLines(content) -- 2213
	local oldLines = splitLines(oldStr) -- 2214
	if #oldLines == 0 then -- 2214
		return {success = false, message = "old_str not found in file"} -- 2216
	end -- 2216
	local dedentedOld = dedentLines(oldLines) -- 2218
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2219
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2220
	local matches = {} -- 2221
	do -- 2221
		local start = 0 -- 2222
		while start <= #contentLines - #oldLines do -- 2222
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2223
			local dedentedCandidate = dedentLines(candidateLines) -- 2224
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2224
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2226
			end -- 2226
			start = start + 1 -- 2222
		end -- 2222
	end -- 2222
	if #matches == 0 then -- 2222
		return {success = false, message = "old_str not found in file"} -- 2234
	end -- 2234
	if #matches > 1 then -- 2234
		return { -- 2237
			success = false, -- 2238
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2239
		} -- 2239
	end -- 2239
	local match = matches[1] -- 2242
	local rebuiltNewLines = __TS__ArrayMap( -- 2243
		dedentedNew.lines, -- 2243
		function(____, line) return line == "" and "" or match.indent .. line end -- 2243
	) -- 2243
	local ____array_38 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2243
	__TS__SparseArrayPush( -- 2243
		____array_38, -- 2243
		table.unpack(rebuiltNewLines) -- 2246
	) -- 2246
	__TS__SparseArrayPush( -- 2246
		____array_38, -- 2246
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2247
	) -- 2247
	local nextLines = {__TS__SparseArraySpread(____array_38)} -- 2244
	return { -- 2249
		success = true, -- 2249
		content = joinLines(nextLines) -- 2249
	} -- 2249
end -- 2208
local MainDecisionAgent = __TS__Class() -- 2252
MainDecisionAgent.name = "MainDecisionAgent" -- 2252
__TS__ClassExtends(MainDecisionAgent, Node) -- 2252
function MainDecisionAgent.prototype.prep(self, shared) -- 2253
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2253
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2253
			return ____awaiter_resolve(nil, {shared = shared}) -- 2253
		end -- 2253
		__TS__Await(maybeCompressHistory(shared)) -- 2258
		return ____awaiter_resolve(nil, {shared = shared}) -- 2258
	end) -- 2258
end -- 2253
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2263
	if attempt == nil then -- 2263
		attempt = 1 -- 2266
	end -- 2266
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2266
		if shared.stopToken.stopped then -- 2266
			return ____awaiter_resolve( -- 2266
				nil, -- 2266
				{ -- 2270
					success = false, -- 2270
					message = getCancelledReason(shared) -- 2270
				} -- 2270
			) -- 2270
		end -- 2270
		Log( -- 2272
			"Info", -- 2272
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2272
		) -- 2272
		local tools = buildDecisionToolSchema(shared) -- 2273
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2274
		local stepId = shared.step + 1 -- 2275
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2276
		saveStepLLMDebugInput( -- 2280
			shared, -- 2280
			stepId, -- 2280
			"decision_tool_calling", -- 2280
			messages, -- 2280
			llmOptions -- 2280
		) -- 2280
		local lastStreamContent = "" -- 2281
		local lastStreamReasoning = "" -- 2282
		local res = __TS__Await(callLLMStreamAggregated( -- 2283
			messages, -- 2284
			llmOptions, -- 2285
			shared.stopToken, -- 2286
			shared.llmConfig, -- 2287
			function(response) -- 2288
				local ____opt_41 = response.choices -- 2288
				local ____opt_39 = ____opt_41 and ____opt_41[1] -- 2288
				local streamMessage = ____opt_39 and ____opt_39.message -- 2289
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2290
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2293
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2293
					return -- 2297
				end -- 2297
				lastStreamContent = nextContent -- 2299
				lastStreamReasoning = nextReasoning -- 2300
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2301
			end -- 2288
		)) -- 2288
		if shared.stopToken.stopped then -- 2288
			return ____awaiter_resolve( -- 2288
				nil, -- 2288
				{ -- 2305
					success = false, -- 2305
					message = getCancelledReason(shared) -- 2305
				} -- 2305
			) -- 2305
		end -- 2305
		if not res.success then -- 2305
			saveStepLLMDebugOutput( -- 2308
				shared, -- 2308
				stepId, -- 2308
				"decision_tool_calling", -- 2308
				res.raw or res.message, -- 2308
				{success = false} -- 2308
			) -- 2308
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2309
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2309
		end -- 2309
		saveStepLLMDebugOutput( -- 2312
			shared, -- 2312
			stepId, -- 2312
			"decision_tool_calling", -- 2312
			encodeDebugJSON(res.response), -- 2312
			{success = true} -- 2312
		) -- 2312
		local choice = res.response.choices and res.response.choices[1] -- 2313
		local message = choice and choice.message -- 2314
		local toolCalls = message and message.tool_calls -- 2315
		local toolCall = toolCalls and toolCalls[1] -- 2316
		local fn = toolCall and toolCall["function"] -- 2317
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2318
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2321
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2324
		Log( -- 2327
			"Info", -- 2327
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2327
		) -- 2327
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2327
			if messageContent and messageContent ~= "" then -- 2327
				Log( -- 2330
					"Info", -- 2330
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2330
				) -- 2330
				return ____awaiter_resolve(nil, { -- 2330
					success = true, -- 2332
					tool = "finish", -- 2333
					params = {}, -- 2334
					reason = messageContent, -- 2335
					reasoningContent = reasoningContent, -- 2336
					directSummary = messageContent -- 2337
				}) -- 2337
			end -- 2337
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2340
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2340
		end -- 2340
		local functionName = fn.name -- 2347
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2348
		Log( -- 2349
			"Info", -- 2349
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2349
		) -- 2349
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2350
			local rawObj, err = safeJsonDecode(argsText) -- 2351
			if err ~= nil or rawObj == nil then -- 2351
				return {__error = tostring(err)} -- 2353
			end -- 2353
			return rawObj -- 2355
		end)() -- 2350
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2350
			local err = tostring(rawArgs.__error) -- 2358
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2359
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2359
		end -- 2359
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2366
		if not decision.success then -- 2366
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2368
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2368
		end -- 2368
		local validation = validateDecision(decision.tool, decision.params) -- 2375
		if not validation.success then -- 2375
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2377
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2377
		end -- 2377
		if not isToolAllowedForRole(shared.role, decision.tool) then -- 2377
			return ____awaiter_resolve(nil, {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText}) -- 2377
		end -- 2377
		decision.params = validation.params -- 2391
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2392
		decision.reason = messageContent -- 2393
		decision.reasoningContent = reasoningContent -- 2394
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2395
		return ____awaiter_resolve(nil, decision) -- 2395
	end) -- 2395
end -- 2263
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2399
		Log( -- 2404
			"Info", -- 2404
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2404
		) -- 2404
		local lastError = initialError -- 2405
		local candidateRaw = "" -- 2406
		do -- 2406
			local attempt = 0 -- 2407
			while attempt < shared.llmMaxTry do -- 2407
				do -- 2407
					Log( -- 2408
						"Info", -- 2408
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2408
					) -- 2408
					local messages = buildXmlRepairMessages( -- 2409
						shared, -- 2410
						originalRaw, -- 2411
						candidateRaw, -- 2412
						lastError, -- 2413
						attempt + 1 -- 2414
					) -- 2414
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2416
					if shared.stopToken.stopped then -- 2416
						return ____awaiter_resolve( -- 2416
							nil, -- 2416
							{ -- 2418
								success = false, -- 2418
								message = getCancelledReason(shared) -- 2418
							} -- 2418
						) -- 2418
					end -- 2418
					if not llmRes.success then -- 2418
						lastError = llmRes.message -- 2421
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2422
						goto __continue384 -- 2423
					end -- 2423
					candidateRaw = llmRes.text -- 2425
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2426
					if decision.success then -- 2426
						decision.reasoningContent = llmRes.reasoningContent -- 2428
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2429
						return ____awaiter_resolve(nil, decision) -- 2429
					end -- 2429
					lastError = decision.message -- 2432
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2433
				end -- 2433
				::__continue384:: -- 2433
				attempt = attempt + 1 -- 2407
			end -- 2407
		end -- 2407
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2435
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2435
	end) -- 2435
end -- 2399
function MainDecisionAgent.prototype.exec(self, input) -- 2443
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2443
		local shared = input.shared -- 2444
		if shared.stopToken.stopped then -- 2444
			return ____awaiter_resolve( -- 2444
				nil, -- 2444
				{ -- 2446
					success = false, -- 2446
					message = getCancelledReason(shared) -- 2446
				} -- 2446
			) -- 2446
		end -- 2446
		if shared.step >= shared.maxSteps then -- 2446
			Log( -- 2449
				"Warn", -- 2449
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2449
			) -- 2449
			return ____awaiter_resolve( -- 2449
				nil, -- 2449
				{ -- 2450
					success = false, -- 2450
					message = getMaxStepsReachedReason(shared) -- 2450
				} -- 2450
			) -- 2450
		end -- 2450
		if shared.decisionMode == "tool_calling" then -- 2450
			Log( -- 2454
				"Info", -- 2454
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2454
			) -- 2454
			local lastError = "tool calling validation failed" -- 2455
			local lastRaw = "" -- 2456
			do -- 2456
				local attempt = 0 -- 2457
				while attempt < shared.llmMaxTry do -- 2457
					Log( -- 2458
						"Info", -- 2458
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2458
					) -- 2458
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2459
					if shared.stopToken.stopped then -- 2459
						return ____awaiter_resolve( -- 2459
							nil, -- 2459
							{ -- 2466
								success = false, -- 2466
								message = getCancelledReason(shared) -- 2466
							} -- 2466
						) -- 2466
					end -- 2466
					if decision.success then -- 2466
						return ____awaiter_resolve(nil, decision) -- 2466
					end -- 2466
					lastError = decision.message -- 2471
					lastRaw = decision.raw or "" -- 2472
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2473
					attempt = attempt + 1 -- 2457
				end -- 2457
			end -- 2457
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2475
			return ____awaiter_resolve( -- 2475
				nil, -- 2475
				{ -- 2476
					success = false, -- 2476
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2476
				} -- 2476
			) -- 2476
		end -- 2476
		local lastError = "xml validation failed" -- 2479
		local lastRaw = "" -- 2480
		do -- 2480
			local attempt = 0 -- 2481
			while attempt < shared.llmMaxTry do -- 2481
				do -- 2481
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2482
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2490
					if shared.stopToken.stopped then -- 2490
						return ____awaiter_resolve( -- 2490
							nil, -- 2490
							{ -- 2492
								success = false, -- 2492
								message = getCancelledReason(shared) -- 2492
							} -- 2492
						) -- 2492
					end -- 2492
					if not llmRes.success then -- 2492
						lastError = llmRes.message -- 2495
						lastRaw = llmRes.text or "" -- 2496
						goto __continue397 -- 2497
					end -- 2497
					lastRaw = llmRes.text -- 2499
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2500
					if decision.success then -- 2500
						decision.reasoningContent = llmRes.reasoningContent -- 2502
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2502
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2504
							return ____awaiter_resolve( -- 2504
								nil, -- 2504
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2505
							) -- 2505
						end -- 2505
						return ____awaiter_resolve(nil, decision) -- 2505
					end -- 2505
					lastError = decision.message -- 2509
					return ____awaiter_resolve( -- 2509
						nil, -- 2509
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2510
					) -- 2510
				end -- 2510
				::__continue397:: -- 2510
				attempt = attempt + 1 -- 2481
			end -- 2481
		end -- 2481
		return ____awaiter_resolve( -- 2481
			nil, -- 2481
			{ -- 2512
				success = false, -- 2512
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2512
			} -- 2512
		) -- 2512
	end) -- 2512
end -- 2443
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2515
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2515
		local result = execRes -- 2516
		if not result.success then -- 2516
			if shared.stopToken.stopped then -- 2516
				shared.error = getCancelledReason(shared) -- 2519
				shared.done = true -- 2520
				return ____awaiter_resolve(nil, "done") -- 2520
			end -- 2520
			shared.error = result.message -- 2523
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2524
			shared.done = true -- 2525
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2526
			persistHistoryState(shared) -- 2530
			return ____awaiter_resolve(nil, "done") -- 2530
		end -- 2530
		if result.directSummary and result.directSummary ~= "" then -- 2530
			shared.response = result.directSummary -- 2534
			shared.done = true -- 2535
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2536
			persistHistoryState(shared) -- 2541
			return ____awaiter_resolve(nil, "done") -- 2541
		end -- 2541
		if result.tool == "finish" then -- 2541
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2545
			shared.response = finalMessage -- 2546
			shared.done = true -- 2547
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2548
			persistHistoryState(shared) -- 2553
			return ____awaiter_resolve(nil, "done") -- 2553
		end -- 2553
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2556
		shared.step = shared.step + 1 -- 2557
		local step = shared.step -- 2558
		emitAgentEvent(shared, { -- 2559
			type = "decision_made", -- 2560
			sessionId = shared.sessionId, -- 2561
			taskId = shared.taskId, -- 2562
			step = step, -- 2563
			tool = result.tool, -- 2564
			reason = result.reason, -- 2565
			reasoningContent = result.reasoningContent, -- 2566
			params = result.params -- 2567
		}) -- 2567
		local ____shared_history_47 = shared.history -- 2567
		____shared_history_47[#____shared_history_47 + 1] = { -- 2569
			step = step, -- 2570
			toolCallId = toolCallId, -- 2571
			tool = result.tool, -- 2572
			reason = result.reason or "", -- 2573
			reasoningContent = result.reasoningContent, -- 2574
			params = result.params, -- 2575
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2576
		} -- 2576
		appendConversationMessage( -- 2578
			shared, -- 2578
			{ -- 2578
				role = "assistant", -- 2579
				content = result.reason or "", -- 2580
				reasoning_content = result.reasoningContent, -- 2581
				tool_calls = {{ -- 2582
					id = toolCallId, -- 2583
					type = "function", -- 2584
					["function"] = { -- 2585
						name = result.tool, -- 2586
						arguments = toJson(result.params) -- 2587
					} -- 2587
				}} -- 2587
			} -- 2587
		) -- 2587
		persistHistoryState(shared) -- 2591
		return ____awaiter_resolve(nil, result.tool) -- 2591
	end) -- 2591
end -- 2515
local ReadFileAction = __TS__Class() -- 2596
ReadFileAction.name = "ReadFileAction" -- 2596
__TS__ClassExtends(ReadFileAction, Node) -- 2596
function ReadFileAction.prototype.prep(self, shared) -- 2597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2597
		local last = shared.history[#shared.history] -- 2598
		if not last then -- 2598
			error( -- 2599
				__TS__New(Error, "no history"), -- 2599
				0 -- 2599
			) -- 2599
		end -- 2599
		emitAgentStartEvent(shared, last) -- 2600
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2601
		if __TS__StringTrim(path) == "" then -- 2601
			error( -- 2604
				__TS__New(Error, "missing path"), -- 2604
				0 -- 2604
			) -- 2604
		end -- 2604
		local ____path_50 = path -- 2606
		local ____shared_workingDir_51 = shared.workingDir -- 2608
		local ____temp_52 = shared.useChineseResponse and "zh" or "en" -- 2609
		local ____last_params_startLine_48 = last.params.startLine -- 2610
		if ____last_params_startLine_48 == nil then -- 2610
			____last_params_startLine_48 = 1 -- 2610
		end -- 2610
		local ____TS__Number_result_53 = __TS__Number(____last_params_startLine_48) -- 2610
		local ____last_params_endLine_49 = last.params.endLine -- 2611
		if ____last_params_endLine_49 == nil then -- 2611
			____last_params_endLine_49 = READ_FILE_DEFAULT_LIMIT -- 2611
		end -- 2611
		return ____awaiter_resolve( -- 2611
			nil, -- 2611
			{ -- 2605
				path = ____path_50, -- 2606
				tool = "read_file", -- 2607
				workDir = ____shared_workingDir_51, -- 2608
				docLanguage = ____temp_52, -- 2609
				startLine = ____TS__Number_result_53, -- 2610
				endLine = __TS__Number(____last_params_endLine_49) -- 2611
			} -- 2611
		) -- 2611
	end) -- 2611
end -- 2597
function ReadFileAction.prototype.exec(self, input) -- 2615
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2615
		return ____awaiter_resolve( -- 2615
			nil, -- 2615
			Tools.readFile( -- 2616
				input.workDir, -- 2617
				input.path, -- 2618
				__TS__Number(input.startLine or 1), -- 2619
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2620
				input.docLanguage -- 2621
			) -- 2621
		) -- 2621
	end) -- 2621
end -- 2615
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2625
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2625
		local result = execRes -- 2626
		local last = shared.history[#shared.history] -- 2627
		if last ~= nil then -- 2627
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2629
			appendToolResultMessage(shared, last) -- 2630
			emitAgentFinishEvent(shared, last) -- 2631
		end -- 2631
		persistHistoryState(shared) -- 2633
		__TS__Await(maybeCompressHistory(shared)) -- 2634
		persistHistoryState(shared) -- 2635
		return ____awaiter_resolve(nil, "main") -- 2635
	end) -- 2635
end -- 2625
local SearchFilesAction = __TS__Class() -- 2640
SearchFilesAction.name = "SearchFilesAction" -- 2640
__TS__ClassExtends(SearchFilesAction, Node) -- 2640
function SearchFilesAction.prototype.prep(self, shared) -- 2641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2641
		local last = shared.history[#shared.history] -- 2642
		if not last then -- 2642
			error( -- 2643
				__TS__New(Error, "no history"), -- 2643
				0 -- 2643
			) -- 2643
		end -- 2643
		emitAgentStartEvent(shared, last) -- 2644
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2644
	end) -- 2644
end -- 2641
function SearchFilesAction.prototype.exec(self, input) -- 2648
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2648
		local params = input.params -- 2649
		local ____Tools_searchFiles_67 = Tools.searchFiles -- 2650
		local ____input_workDir_60 = input.workDir -- 2651
		local ____temp_61 = params.path or "" -- 2652
		local ____temp_62 = params.pattern or "" -- 2653
		local ____params_globs_63 = params.globs -- 2654
		local ____params_useRegex_64 = params.useRegex -- 2655
		local ____params_caseSensitive_65 = params.caseSensitive -- 2656
		local ____math_max_56 = math.max -- 2659
		local ____math_floor_55 = math.floor -- 2659
		local ____params_limit_54 = params.limit -- 2659
		if ____params_limit_54 == nil then -- 2659
			____params_limit_54 = SEARCH_FILES_LIMIT_DEFAULT -- 2659
		end -- 2659
		local ____math_max_56_result_66 = ____math_max_56( -- 2659
			1, -- 2659
			____math_floor_55(__TS__Number(____params_limit_54)) -- 2659
		) -- 2659
		local ____math_max_59 = math.max -- 2660
		local ____math_floor_58 = math.floor -- 2660
		local ____params_offset_57 = params.offset -- 2660
		if ____params_offset_57 == nil then -- 2660
			____params_offset_57 = 0 -- 2660
		end -- 2660
		local result = __TS__Await(____Tools_searchFiles_67({ -- 2650
			workDir = ____input_workDir_60, -- 2651
			path = ____temp_61, -- 2652
			pattern = ____temp_62, -- 2653
			globs = ____params_globs_63, -- 2654
			useRegex = ____params_useRegex_64, -- 2655
			caseSensitive = ____params_caseSensitive_65, -- 2656
			includeContent = true, -- 2657
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2658
			limit = ____math_max_56_result_66, -- 2659
			offset = ____math_max_59( -- 2660
				0, -- 2660
				____math_floor_58(__TS__Number(____params_offset_57)) -- 2660
			), -- 2660
			groupByFile = params.groupByFile == true -- 2661
		})) -- 2661
		return ____awaiter_resolve(nil, result) -- 2661
	end) -- 2661
end -- 2648
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2666
		local last = shared.history[#shared.history] -- 2667
		if last ~= nil then -- 2667
			local result = execRes -- 2669
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2670
			appendToolResultMessage(shared, last) -- 2671
			emitAgentFinishEvent(shared, last) -- 2672
		end -- 2672
		persistHistoryState(shared) -- 2674
		__TS__Await(maybeCompressHistory(shared)) -- 2675
		persistHistoryState(shared) -- 2676
		return ____awaiter_resolve(nil, "main") -- 2676
	end) -- 2676
end -- 2666
local SearchDoraAPIAction = __TS__Class() -- 2681
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2681
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2681
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2682
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2682
		local last = shared.history[#shared.history] -- 2683
		if not last then -- 2683
			error( -- 2684
				__TS__New(Error, "no history"), -- 2684
				0 -- 2684
			) -- 2684
		end -- 2684
		emitAgentStartEvent(shared, last) -- 2685
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2685
	end) -- 2685
end -- 2682
function SearchDoraAPIAction.prototype.exec(self, input) -- 2689
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2689
		local params = input.params -- 2690
		local ____Tools_searchDoraAPI_75 = Tools.searchDoraAPI -- 2691
		local ____temp_71 = params.pattern or "" -- 2692
		local ____temp_72 = params.docSource or "api" -- 2693
		local ____temp_73 = input.useChineseResponse and "zh" or "en" -- 2694
		local ____temp_74 = params.programmingLanguage or "ts" -- 2695
		local ____math_min_70 = math.min -- 2696
		local ____math_max_69 = math.max -- 2696
		local ____params_limit_68 = params.limit -- 2696
		if ____params_limit_68 == nil then -- 2696
			____params_limit_68 = 8 -- 2696
		end -- 2696
		local result = __TS__Await(____Tools_searchDoraAPI_75({ -- 2691
			pattern = ____temp_71, -- 2692
			docSource = ____temp_72, -- 2693
			docLanguage = ____temp_73, -- 2694
			programmingLanguage = ____temp_74, -- 2695
			limit = ____math_min_70( -- 2696
				SEARCH_DORA_API_LIMIT_MAX, -- 2696
				____math_max_69( -- 2696
					1, -- 2696
					__TS__Number(____params_limit_68) -- 2696
				) -- 2696
			), -- 2696
			useRegex = params.useRegex, -- 2697
			caseSensitive = false, -- 2698
			includeContent = true, -- 2699
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2700
		})) -- 2700
		return ____awaiter_resolve(nil, result) -- 2700
	end) -- 2700
end -- 2689
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2705
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2705
		local last = shared.history[#shared.history] -- 2706
		if last ~= nil then -- 2706
			local result = execRes -- 2708
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2709
			appendToolResultMessage(shared, last) -- 2710
			emitAgentFinishEvent(shared, last) -- 2711
		end -- 2711
		persistHistoryState(shared) -- 2713
		__TS__Await(maybeCompressHistory(shared)) -- 2714
		persistHistoryState(shared) -- 2715
		return ____awaiter_resolve(nil, "main") -- 2715
	end) -- 2715
end -- 2705
local ListFilesAction = __TS__Class() -- 2720
ListFilesAction.name = "ListFilesAction" -- 2720
__TS__ClassExtends(ListFilesAction, Node) -- 2720
function ListFilesAction.prototype.prep(self, shared) -- 2721
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2721
		local last = shared.history[#shared.history] -- 2722
		if not last then -- 2722
			error( -- 2723
				__TS__New(Error, "no history"), -- 2723
				0 -- 2723
			) -- 2723
		end -- 2723
		emitAgentStartEvent(shared, last) -- 2724
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2724
	end) -- 2724
end -- 2721
function ListFilesAction.prototype.exec(self, input) -- 2728
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2728
		local params = input.params -- 2729
		local ____Tools_listFiles_82 = Tools.listFiles -- 2730
		local ____input_workDir_79 = input.workDir -- 2731
		local ____temp_80 = params.path or "" -- 2732
		local ____params_globs_81 = params.globs -- 2733
		local ____math_max_78 = math.max -- 2734
		local ____math_floor_77 = math.floor -- 2734
		local ____params_maxEntries_76 = params.maxEntries -- 2734
		if ____params_maxEntries_76 == nil then -- 2734
			____params_maxEntries_76 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2734
		end -- 2734
		local result = ____Tools_listFiles_82({ -- 2730
			workDir = ____input_workDir_79, -- 2731
			path = ____temp_80, -- 2732
			globs = ____params_globs_81, -- 2733
			maxEntries = ____math_max_78( -- 2734
				1, -- 2734
				____math_floor_77(__TS__Number(____params_maxEntries_76)) -- 2734
			) -- 2734
		}) -- 2734
		return ____awaiter_resolve(nil, result) -- 2734
	end) -- 2734
end -- 2728
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2739
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2739
		local last = shared.history[#shared.history] -- 2740
		if last ~= nil then -- 2740
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2742
			appendToolResultMessage(shared, last) -- 2743
			emitAgentFinishEvent(shared, last) -- 2744
		end -- 2744
		persistHistoryState(shared) -- 2746
		__TS__Await(maybeCompressHistory(shared)) -- 2747
		persistHistoryState(shared) -- 2748
		return ____awaiter_resolve(nil, "main") -- 2748
	end) -- 2748
end -- 2739
local DeleteFileAction = __TS__Class() -- 2753
DeleteFileAction.name = "DeleteFileAction" -- 2753
__TS__ClassExtends(DeleteFileAction, Node) -- 2753
function DeleteFileAction.prototype.prep(self, shared) -- 2754
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2754
		local last = shared.history[#shared.history] -- 2755
		if not last then -- 2755
			error( -- 2756
				__TS__New(Error, "no history"), -- 2756
				0 -- 2756
			) -- 2756
		end -- 2756
		emitAgentStartEvent(shared, last) -- 2757
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2758
		if __TS__StringTrim(targetFile) == "" then -- 2758
			error( -- 2761
				__TS__New(Error, "missing target_file"), -- 2761
				0 -- 2761
			) -- 2761
		end -- 2761
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2761
	end) -- 2761
end -- 2754
function DeleteFileAction.prototype.exec(self, input) -- 2765
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2765
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2766
		if not result.success then -- 2766
			return ____awaiter_resolve(nil, result) -- 2766
		end -- 2766
		return ____awaiter_resolve(nil, { -- 2766
			success = true, -- 2774
			changed = true, -- 2775
			mode = "delete", -- 2776
			checkpointId = result.checkpointId, -- 2777
			checkpointSeq = result.checkpointSeq, -- 2778
			files = {{path = input.targetFile, op = "delete"}} -- 2779
		}) -- 2779
	end) -- 2779
end -- 2765
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2783
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2783
		local last = shared.history[#shared.history] -- 2784
		if last ~= nil then -- 2784
			last.result = execRes -- 2786
			appendToolResultMessage(shared, last) -- 2787
			emitAgentFinishEvent(shared, last) -- 2788
			local result = last.result -- 2789
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2789
				emitAgentEvent(shared, { -- 2794
					type = "checkpoint_created", -- 2795
					sessionId = shared.sessionId, -- 2796
					taskId = shared.taskId, -- 2797
					step = last.step, -- 2798
					tool = "delete_file", -- 2799
					checkpointId = result.checkpointId, -- 2800
					checkpointSeq = result.checkpointSeq, -- 2801
					files = result.files -- 2802
				}) -- 2802
			end -- 2802
		end -- 2802
		persistHistoryState(shared) -- 2806
		__TS__Await(maybeCompressHistory(shared)) -- 2807
		persistHistoryState(shared) -- 2808
		return ____awaiter_resolve(nil, "main") -- 2808
	end) -- 2808
end -- 2783
local BuildAction = __TS__Class() -- 2813
BuildAction.name = "BuildAction" -- 2813
__TS__ClassExtends(BuildAction, Node) -- 2813
function BuildAction.prototype.prep(self, shared) -- 2814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2814
		local last = shared.history[#shared.history] -- 2815
		if not last then -- 2815
			error( -- 2816
				__TS__New(Error, "no history"), -- 2816
				0 -- 2816
			) -- 2816
		end -- 2816
		emitAgentStartEvent(shared, last) -- 2817
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2817
	end) -- 2817
end -- 2814
function BuildAction.prototype.exec(self, input) -- 2821
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2821
		local params = input.params -- 2822
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2823
		return ____awaiter_resolve(nil, result) -- 2823
	end) -- 2823
end -- 2821
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2830
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2830
		local last = shared.history[#shared.history] -- 2831
		if last ~= nil then -- 2831
			last.result = execRes -- 2833
			appendToolResultMessage(shared, last) -- 2834
			emitAgentFinishEvent(shared, last) -- 2835
		end -- 2835
		persistHistoryState(shared) -- 2837
		__TS__Await(maybeCompressHistory(shared)) -- 2838
		persistHistoryState(shared) -- 2839
		return ____awaiter_resolve(nil, "main") -- 2839
	end) -- 2839
end -- 2830
local SpawnSubAgentAction = __TS__Class() -- 2844
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2844
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2844
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2845
		local last = shared.history[#shared.history] -- 2854
		if not last then -- 2854
			error( -- 2855
				__TS__New(Error, "no history"), -- 2855
				0 -- 2855
			) -- 2855
		end -- 2855
		emitAgentStartEvent(shared, last) -- 2856
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2857
			last.params.filesHint, -- 2858
			function(____, item) return type(item) == "string" end -- 2858
		) or nil -- 2858
		return ____awaiter_resolve( -- 2858
			nil, -- 2858
			{ -- 2860
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2861
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2862
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2863
				filesHint = filesHint, -- 2864
				sessionId = shared.sessionId, -- 2865
				projectRoot = shared.workingDir, -- 2866
				spawnSubAgent = shared.spawnSubAgent -- 2867
			} -- 2867
		) -- 2867
	end) -- 2867
end -- 2845
function SpawnSubAgentAction.prototype.exec(self, input) -- 2871
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2871
		if not input.spawnSubAgent then -- 2871
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2871
		end -- 2871
		if input.sessionId == nil or input.sessionId <= 0 then -- 2871
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2871
		end -- 2871
		local ____Log_88 = Log -- 2886
		local ____temp_85 = #input.title -- 2886
		local ____temp_86 = #input.prompt -- 2886
		local ____temp_87 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2886
		local ____opt_83 = input.filesHint -- 2886
		____Log_88( -- 2886
			"Info", -- 2886
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_85)) .. " prompt_len=") .. tostring(____temp_86)) .. " expected_len=") .. tostring(____temp_87)) .. " files_hint_count=") .. tostring(____opt_83 and #____opt_83 or 0) -- 2886
		) -- 2886
		local result = __TS__Await(input:spawnSubAgent({ -- 2887
			parentSessionId = input.sessionId, -- 2888
			projectRoot = input.projectRoot, -- 2889
			title = input.title, -- 2890
			prompt = input.prompt, -- 2891
			expectedOutput = input.expectedOutput, -- 2892
			filesHint = input.filesHint -- 2893
		})) -- 2893
		if not result.success then -- 2893
			return ____awaiter_resolve(nil, result) -- 2893
		end -- 2893
		return ____awaiter_resolve(nil, { -- 2893
			success = true, -- 2899
			sessionId = result.sessionId, -- 2900
			taskId = result.taskId, -- 2901
			title = result.title, -- 2902
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 2903
		}) -- 2903
	end) -- 2903
end -- 2871
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 2907
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2907
		local last = shared.history[#shared.history] -- 2908
		if last ~= nil then -- 2908
			last.result = execRes -- 2910
			appendToolResultMessage(shared, last) -- 2911
			emitAgentFinishEvent(shared, last) -- 2912
		end -- 2912
		persistHistoryState(shared) -- 2914
		__TS__Await(maybeCompressHistory(shared)) -- 2915
		persistHistoryState(shared) -- 2916
		return ____awaiter_resolve(nil, "main") -- 2916
	end) -- 2916
end -- 2907
local ListSubAgentsAction = __TS__Class() -- 2921
ListSubAgentsAction.name = "ListSubAgentsAction" -- 2921
__TS__ClassExtends(ListSubAgentsAction, Node) -- 2921
function ListSubAgentsAction.prototype.prep(self, shared) -- 2922
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2922
		local last = shared.history[#shared.history] -- 2931
		if not last then -- 2931
			error( -- 2932
				__TS__New(Error, "no history"), -- 2932
				0 -- 2932
			) -- 2932
		end -- 2932
		emitAgentStartEvent(shared, last) -- 2933
		return ____awaiter_resolve( -- 2933
			nil, -- 2933
			{ -- 2934
				sessionId = shared.sessionId, -- 2935
				projectRoot = shared.workingDir, -- 2936
				status = type(last.params.status) == "string" and last.params.status or nil, -- 2937
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 2938
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 2939
				query = type(last.params.query) == "string" and last.params.query or nil, -- 2940
				listSubAgents = shared.listSubAgents -- 2941
			} -- 2941
		) -- 2941
	end) -- 2941
end -- 2922
function ListSubAgentsAction.prototype.exec(self, input) -- 2945
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2945
		if not input.listSubAgents then -- 2945
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 2945
		end -- 2945
		if input.sessionId == nil or input.sessionId <= 0 then -- 2945
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 2945
		end -- 2945
		local result = __TS__Await(input:listSubAgents({ -- 2960
			sessionId = input.sessionId, -- 2961
			projectRoot = input.projectRoot, -- 2962
			status = input.status, -- 2963
			limit = input.limit, -- 2964
			offset = input.offset, -- 2965
			query = input.query -- 2966
		})) -- 2966
		return ____awaiter_resolve(nil, result) -- 2966
	end) -- 2966
end -- 2945
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 2971
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2971
		local last = shared.history[#shared.history] -- 2972
		if last ~= nil then -- 2972
			last.result = execRes -- 2974
			appendToolResultMessage(shared, last) -- 2975
			emitAgentFinishEvent(shared, last) -- 2976
		end -- 2976
		persistHistoryState(shared) -- 2978
		__TS__Await(maybeCompressHistory(shared)) -- 2979
		persistHistoryState(shared) -- 2980
		return ____awaiter_resolve(nil, "main") -- 2980
	end) -- 2980
end -- 2971
local EditFileAction = __TS__Class() -- 2985
EditFileAction.name = "EditFileAction" -- 2985
__TS__ClassExtends(EditFileAction, Node) -- 2985
function EditFileAction.prototype.prep(self, shared) -- 2986
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2986
		local last = shared.history[#shared.history] -- 2987
		if not last then -- 2987
			error( -- 2988
				__TS__New(Error, "no history"), -- 2988
				0 -- 2988
			) -- 2988
		end -- 2988
		emitAgentStartEvent(shared, last) -- 2989
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2990
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2993
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2994
		if __TS__StringTrim(path) == "" then -- 2994
			error( -- 2995
				__TS__New(Error, "missing path"), -- 2995
				0 -- 2995
			) -- 2995
		end -- 2995
		return ____awaiter_resolve(nil, { -- 2995
			path = path, -- 2996
			oldStr = oldStr, -- 2996
			newStr = newStr, -- 2996
			taskId = shared.taskId, -- 2996
			workDir = shared.workingDir -- 2996
		}) -- 2996
	end) -- 2996
end -- 2986
function EditFileAction.prototype.exec(self, input) -- 2999
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2999
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3000
		if not readRes.success then -- 3000
			if input.oldStr ~= "" then -- 3000
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3000
			end -- 3000
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3005
			if not createRes.success then -- 3005
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3005
			end -- 3005
			return ____awaiter_resolve(nil, { -- 3005
				success = true, -- 3013
				changed = true, -- 3014
				mode = "create", -- 3015
				checkpointId = createRes.checkpointId, -- 3016
				checkpointSeq = createRes.checkpointSeq, -- 3017
				files = {{path = input.path, op = "create"}} -- 3018
			}) -- 3018
		end -- 3018
		if input.oldStr == "" then -- 3018
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3022
			if not overwriteRes.success then -- 3022
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3022
			end -- 3022
			return ____awaiter_resolve(nil, { -- 3022
				success = true, -- 3030
				changed = true, -- 3031
				mode = "overwrite", -- 3032
				checkpointId = overwriteRes.checkpointId, -- 3033
				checkpointSeq = overwriteRes.checkpointSeq, -- 3034
				files = {{path = input.path, op = "write"}} -- 3035
			}) -- 3035
		end -- 3035
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3040
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3041
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3042
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3045
		if occurrences == 0 then -- 3045
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3047
			if not indentTolerant.success then -- 3047
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3047
			end -- 3047
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3051
			if not applyRes.success then -- 3051
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3051
			end -- 3051
			return ____awaiter_resolve(nil, { -- 3051
				success = true, -- 3059
				changed = true, -- 3060
				mode = "replace_indent_tolerant", -- 3061
				checkpointId = applyRes.checkpointId, -- 3062
				checkpointSeq = applyRes.checkpointSeq, -- 3063
				files = {{path = input.path, op = "write"}} -- 3064
			}) -- 3064
		end -- 3064
		if occurrences > 1 then -- 3064
			return ____awaiter_resolve( -- 3064
				nil, -- 3064
				{ -- 3068
					success = false, -- 3068
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3068
				} -- 3068
			) -- 3068
		end -- 3068
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3072
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3073
		if not applyRes.success then -- 3073
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3073
		end -- 3073
		return ____awaiter_resolve(nil, { -- 3073
			success = true, -- 3081
			changed = true, -- 3082
			mode = "replace", -- 3083
			checkpointId = applyRes.checkpointId, -- 3084
			checkpointSeq = applyRes.checkpointSeq, -- 3085
			files = {{path = input.path, op = "write"}} -- 3086
		}) -- 3086
	end) -- 3086
end -- 2999
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3090
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3090
		local last = shared.history[#shared.history] -- 3091
		if last ~= nil then -- 3091
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3093
			last.result = execRes -- 3094
			appendToolResultMessage(shared, last) -- 3095
			emitAgentFinishEvent(shared, last) -- 3096
			local result = last.result -- 3097
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3097
				emitAgentEvent(shared, { -- 3102
					type = "checkpoint_created", -- 3103
					sessionId = shared.sessionId, -- 3104
					taskId = shared.taskId, -- 3105
					step = last.step, -- 3106
					tool = last.tool, -- 3107
					checkpointId = result.checkpointId, -- 3108
					checkpointSeq = result.checkpointSeq, -- 3109
					files = result.files -- 3110
				}) -- 3110
			end -- 3110
		end -- 3110
		persistHistoryState(shared) -- 3114
		__TS__Await(maybeCompressHistory(shared)) -- 3115
		persistHistoryState(shared) -- 3116
		return ____awaiter_resolve(nil, "main") -- 3116
	end) -- 3116
end -- 3090
local EndNode = __TS__Class() -- 3121
EndNode.name = "EndNode" -- 3121
__TS__ClassExtends(EndNode, Node) -- 3121
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3122
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3122
		return ____awaiter_resolve(nil, nil) -- 3122
	end) -- 3122
end -- 3122
local CodingAgentFlow = __TS__Class() -- 3127
CodingAgentFlow.name = "CodingAgentFlow" -- 3127
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3127
function CodingAgentFlow.prototype.____constructor(self, role) -- 3128
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3129
	local read = __TS__New(ReadFileAction, 1, 0) -- 3130
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3131
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3132
	local list = __TS__New(ListFilesAction, 1, 0) -- 3133
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3134
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3135
	local build = __TS__New(BuildAction, 1, 0) -- 3136
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3137
	local edit = __TS__New(EditFileAction, 1, 0) -- 3138
	local done = __TS__New(EndNode, 1, 0) -- 3139
	main:on("grep_files", search) -- 3141
	main:on("search_dora_api", searchDora) -- 3142
	main:on("glob_files", list) -- 3143
	if role == "main" then -- 3143
		main:on("read_file", read) -- 3145
		main:on("delete_file", del) -- 3146
		main:on("build", build) -- 3147
		main:on("edit_file", edit) -- 3148
		main:on("list_sub_agents", listSub) -- 3149
		main:on("spawn_sub_agent", spawn) -- 3150
	else -- 3150
		main:on("read_file", read) -- 3152
		main:on("delete_file", del) -- 3153
		main:on("build", build) -- 3154
		main:on("edit_file", edit) -- 3155
	end -- 3155
	main:on("done", done) -- 3157
	search:on("main", main) -- 3159
	searchDora:on("main", main) -- 3160
	list:on("main", main) -- 3161
	listSub:on("main", main) -- 3162
	spawn:on("main", main) -- 3163
	read:on("main", main) -- 3164
	del:on("main", main) -- 3165
	build:on("main", main) -- 3166
	edit:on("main", main) -- 3167
	Flow.prototype.____constructor(self, main) -- 3169
end -- 3128
local function runCodingAgentAsync(options) -- 3191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3191
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3191
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3191
		end -- 3191
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3195
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3196
		if not llmConfigRes.success then -- 3196
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3196
		end -- 3196
		local llmConfig = llmConfigRes.config -- 3202
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3203
		if not taskRes.success then -- 3203
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3203
		end -- 3203
		local compressor = __TS__New(MemoryCompressor, { -- 3210
			compressionThreshold = 0.8, -- 3211
			compressionTargetThreshold = 0.5, -- 3212
			maxCompressionRounds = 3, -- 3213
			projectDir = options.workDir, -- 3214
			llmConfig = llmConfig, -- 3215
			promptPack = options.promptPack, -- 3216
			scope = options.memoryScope -- 3217
		}) -- 3217
		local persistedSession = compressor:getStorage():readSessionState() -- 3219
		local promptPack = compressor:getPromptPack() -- 3220
		local shared = { -- 3222
			sessionId = options.sessionId, -- 3223
			taskId = taskRes.taskId, -- 3224
			role = options.role or "main", -- 3225
			maxSteps = math.max( -- 3226
				1, -- 3226
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3226
			), -- 3226
			llmMaxTry = math.max( -- 3227
				1, -- 3227
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3227
			), -- 3227
			step = 0, -- 3228
			done = false, -- 3229
			stopToken = options.stopToken or ({stopped = false}), -- 3230
			response = "", -- 3231
			userQuery = normalizedPrompt, -- 3232
			workingDir = options.workDir, -- 3233
			useChineseResponse = options.useChineseResponse == true, -- 3234
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3235
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3238
			llmConfig = llmConfig, -- 3239
			onEvent = options.onEvent, -- 3240
			promptPack = promptPack, -- 3241
			history = {}, -- 3242
			messages = persistedSession.messages, -- 3243
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3244
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3245
			memory = {compressor = compressor}, -- 3247
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3251
			spawnSubAgent = options.spawnSubAgent, -- 3256
			listSubAgents = options.listSubAgents -- 3257
		} -- 3257
		local ____try = __TS__AsyncAwaiter(function() -- 3257
			emitAgentEvent(shared, { -- 3261
				type = "task_started", -- 3262
				sessionId = shared.sessionId, -- 3263
				taskId = shared.taskId, -- 3264
				prompt = shared.userQuery, -- 3265
				workDir = shared.workingDir, -- 3266
				maxSteps = shared.maxSteps -- 3267
			}) -- 3267
			if shared.stopToken.stopped then -- 3267
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3270
				return ____awaiter_resolve( -- 3270
					nil, -- 3270
					emitAgentTaskFinishEvent( -- 3271
						shared, -- 3271
						false, -- 3271
						getCancelledReason(shared) -- 3271
					) -- 3271
				) -- 3271
			end -- 3271
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3273
			local promptCommand = getPromptCommand(shared.userQuery) -- 3274
			if promptCommand == "clear" then -- 3274
				return ____awaiter_resolve( -- 3274
					nil, -- 3274
					clearSessionHistory(shared) -- 3276
				) -- 3276
			end -- 3276
			if promptCommand == "compact" then -- 3276
				if shared.role == "sub" then -- 3276
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3280
					return ____awaiter_resolve( -- 3280
						nil, -- 3280
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3281
					) -- 3281
				end -- 3281
				return ____awaiter_resolve( -- 3281
					nil, -- 3281
					__TS__Await(compactAllHistory(shared)) -- 3289
				) -- 3289
			end -- 3289
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3291
			persistHistoryState(shared) -- 3295
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3296
			__TS__Await(flow:run(shared)) -- 3297
			if shared.stopToken.stopped then -- 3297
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3299
				return ____awaiter_resolve( -- 3299
					nil, -- 3299
					emitAgentTaskFinishEvent( -- 3300
						shared, -- 3300
						false, -- 3300
						getCancelledReason(shared) -- 3300
					) -- 3300
				) -- 3300
			end -- 3300
			if shared.error then -- 3300
				return ____awaiter_resolve( -- 3300
					nil, -- 3300
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3303
				) -- 3303
			end -- 3303
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3306
			return ____awaiter_resolve( -- 3306
				nil, -- 3306
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3307
			) -- 3307
		end) -- 3307
		__TS__Await(____try.catch( -- 3260
			____try, -- 3260
			function(____, e) -- 3260
				return ____awaiter_resolve( -- 3260
					nil, -- 3260
					finalizeAgentFailure( -- 3310
						shared, -- 3310
						tostring(e) -- 3310
					) -- 3310
				) -- 3310
			end -- 3310
		)) -- 3310
	end) -- 3310
end -- 3191
function ____exports.runCodingAgent(options, callback) -- 3314
	local ____self_89 = runCodingAgentAsync(options) -- 3314
	____self_89["then"]( -- 3314
		____self_89, -- 3314
		function(____, result) return callback(result) end -- 3315
	) -- 3315
end -- 3314
return ____exports -- 3314