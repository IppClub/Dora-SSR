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
function emitAgentEvent(shared, event) -- 701
	if shared.onEvent then -- 701
		do -- 701
			local function ____catch(____error) -- 701
				Log( -- 706
					"Error", -- 706
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 706
				) -- 706
			end -- 706
			local ____try, ____hasReturned = pcall(function() -- 706
				shared:onEvent(event) -- 704
			end) -- 704
			if not ____try then -- 704
				____catch(____hasReturned) -- 704
			end -- 704
		end -- 704
	end -- 704
end -- 704
function truncateText(text, maxLen) -- 950
	if #text <= maxLen then -- 950
		return text -- 951
	end -- 951
	local nextPos = utf8.offset(text, maxLen + 1) -- 952
	if nextPos == nil then -- 952
		return text -- 953
	end -- 953
	return string.sub(text, 1, nextPos - 1) .. "..." -- 954
end -- 954
function getReplyLanguageDirective(shared) -- 964
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 965
end -- 965
function replacePromptVars(template, vars) -- 970
	local output = template -- 971
	for key in pairs(vars) do -- 972
		output = table.concat( -- 973
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 973
			vars[key] or "" or "," -- 973
		) -- 973
	end -- 973
	return output -- 975
end -- 975
function getDecisionToolDefinitions(shared) -- 1099
	local base = replacePromptVars( -- 1100
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1101
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1102
	) -- 1102
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this whenever the task requires direct coding, file editing, file deletion, build verification, documentation writing, or any other concrete execution work by a delegated sub agent.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1104
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1124
		getAllowedToolsForRole(shared.role), -- 1125
		", " -- 1125
	) or "" -- 1125
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1127
	if (shared and shared.decisionMode) ~= "xml" then -- 1127
		return withRole -- 1129
	end -- 1129
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1131
end -- 1131
function persistHistoryState(shared) -- 1407
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1408
end -- 1408
function getActiveConversationMessages(shared) -- 1415
	local activeMessages = {} -- 1416
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1416
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1423
	end -- 1423
	do -- 1423
		local i = shared.lastConsolidatedIndex -- 1427
		while i < #shared.messages do -- 1427
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1428
			i = i + 1 -- 1427
		end -- 1427
	end -- 1427
	return activeMessages -- 1430
end -- 1430
function getActiveRealMessageCount(shared) -- 1433
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1434
end -- 1434
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1437
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1442
	local previousActiveStart = shared.lastConsolidatedIndex -- 1443
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1444
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1445
	if type(carryMessageIndex) == "number" then -- 1445
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1445
		else -- 1445
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1453
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1456
		end -- 1456
	else -- 1456
		shared.carryMessageIndex = nil -- 1461
	end -- 1461
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1461
		shared.carryMessageIndex = nil -- 1471
	end -- 1471
end -- 1471
function getAllowedToolsForRole(role) -- 1762
	return role == "main" and ({ -- 1763
		"read_file", -- 1764
		"grep_files", -- 1764
		"search_dora_api", -- 1764
		"glob_files", -- 1764
		"list_sub_agents", -- 1764
		"spawn_sub_agent", -- 1764
		"finish" -- 1764
	}) or ({ -- 1764
		"read_file", -- 1765
		"edit_file", -- 1765
		"delete_file", -- 1765
		"grep_files", -- 1765
		"search_dora_api", -- 1765
		"glob_files", -- 1765
		"build", -- 1765
		"finish" -- 1765
	}) -- 1765
end -- 1765
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1871
	if includeToolDefinitions == nil then -- 1871
		includeToolDefinitions = false -- 1871
	end -- 1871
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase using search/discovery tools, and decide when to delegate implementation work by spawning sub agents.\n\nRules:\n- Do not perform direct code editing, deletion, or build actions yourself.\n- Use spawn_sub_agent when the task requires concrete implementation or verification work.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Code changes, file deletion, build/compile verification, and documentation writing should be delegated to a sub agent.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 1872
	local sections = { -- 1896
		shared.promptPack.agentIdentityPrompt, -- 1897
		rolePrompt, -- 1898
		getReplyLanguageDirective(shared) -- 1899
	} -- 1899
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1901
	if memoryContext ~= "" then -- 1901
		sections[#sections + 1] = memoryContext -- 1903
	end -- 1903
	if includeToolDefinitions then -- 1903
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1906
		if shared.decisionMode == "xml" then -- 1906
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1908
		end -- 1908
	end -- 1908
	local skillsSection = buildSkillsSection(shared) -- 1912
	if skillsSection ~= "" then -- 1912
		sections[#sections + 1] = skillsSection -- 1914
	end -- 1914
	return table.concat(sections, "\n\n") -- 1916
end -- 1916
function buildSkillsSection(shared) -- 1919
	local ____opt_32 = shared.skills -- 1919
	if not (____opt_32 and ____opt_32.loader) then -- 1919
		return "" -- 1921
	end -- 1921
	return shared.skills.loader:buildSkillsPromptSection() -- 1923
end -- 1923
function buildXmlDecisionInstruction(shared, feedback) -- 2035
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2036
end -- 2036
function emitAgentTaskFinishEvent(shared, success, message) -- 3138
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3139
	emitAgentEvent(shared, { -- 3145
		type = "task_finished", -- 3146
		sessionId = shared.sessionId, -- 3147
		taskId = shared.taskId, -- 3148
		success = result.success, -- 3149
		message = result.message, -- 3150
		steps = result.steps -- 3151
	}) -- 3151
	return result -- 3153
end -- 3153
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
local function emitAgentStartEvent(shared, action) -- 711
	emitAgentEvent(shared, { -- 712
		type = "tool_started", -- 713
		sessionId = shared.sessionId, -- 714
		taskId = shared.taskId, -- 715
		step = action.step, -- 716
		tool = action.tool -- 717
	}) -- 717
end -- 711
local function emitAgentFinishEvent(shared, action) -- 721
	emitAgentEvent(shared, { -- 722
		type = "tool_finished", -- 723
		sessionId = shared.sessionId, -- 724
		taskId = shared.taskId, -- 725
		step = action.step, -- 726
		tool = action.tool, -- 727
		result = action.result or ({}) -- 728
	}) -- 728
end -- 721
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 732
	emitAgentEvent(shared, { -- 733
		type = "assistant_message_updated", -- 734
		sessionId = shared.sessionId, -- 735
		taskId = shared.taskId, -- 736
		step = shared.step + 1, -- 737
		content = content, -- 738
		reasoningContent = reasoningContent -- 739
	}) -- 739
end -- 732
local function getMemoryCompressionStartReason(shared) -- 743
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 744
end -- 743
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 749
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 750
end -- 749
local function getMemoryCompressionFailureReason(shared, ____error) -- 755
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 756
end -- 755
local function summarizeHistoryEntryPreview(text, maxChars) -- 761
	if maxChars == nil then -- 761
		maxChars = 180 -- 761
	end -- 761
	local trimmed = __TS__StringTrim(text) -- 762
	if trimmed == "" then -- 762
		return "" -- 763
	end -- 763
	return truncateText(trimmed, maxChars) -- 764
end -- 761
local function getCancelledReason(shared) -- 767
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 767
		return shared.stopToken.reason -- 768
	end -- 768
	return shared.useChineseResponse and "已取消" or "cancelled" -- 769
end -- 767
local function getMaxStepsReachedReason(shared) -- 772
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 773
end -- 772
local function getFailureSummaryFallback(shared, ____error) -- 778
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 779
end -- 778
local function finalizeAgentFailure(shared, ____error) -- 784
	if shared.stopToken.stopped then -- 784
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 786
		return emitAgentTaskFinishEvent( -- 787
			shared, -- 787
			false, -- 787
			getCancelledReason(shared) -- 787
		) -- 787
	end -- 787
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 789
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 790
end -- 784
local function getPromptCommand(prompt) -- 793
	local trimmed = __TS__StringTrim(prompt) -- 794
	if trimmed == "/compact" then -- 794
		return "compact" -- 795
	end -- 795
	if trimmed == "/reset" then -- 795
		return "reset" -- 796
	end -- 796
	return nil -- 797
end -- 793
function ____exports.truncateAgentUserPrompt(prompt) -- 800
	if not prompt then -- 800
		return "" -- 801
	end -- 801
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 801
		return prompt -- 802
	end -- 802
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 803
	if offset == nil then -- 803
		return prompt -- 804
	end -- 804
	return string.sub(prompt, 1, offset - 1) -- 805
end -- 800
local function canWriteStepLLMDebug(shared, stepId) -- 808
	if stepId == nil then -- 808
		stepId = shared.step + 1 -- 808
	end -- 808
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 809
end -- 808
local function ensureDirRecursive(dir) -- 816
	if not dir then -- 816
		return false -- 817
	end -- 817
	if Content:exist(dir) then -- 817
		return Content:isdir(dir) -- 818
	end -- 818
	local parent = Path:getPath(dir) -- 819
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 819
		return false -- 821
	end -- 821
	return Content:mkdir(dir) -- 823
end -- 816
local function encodeDebugJSON(value) -- 826
	local text, err = safeJsonEncode(value) -- 827
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 828
end -- 826
local function getStepLLMDebugDir(shared) -- 831
	return Path( -- 832
		shared.workingDir, -- 833
		".agent", -- 834
		tostring(shared.sessionId), -- 835
		tostring(shared.taskId) -- 836
	) -- 836
end -- 831
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 840
	return Path( -- 841
		getStepLLMDebugDir(shared), -- 841
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 841
	) -- 841
end -- 840
local function getLatestStepLLMDebugSeq(shared, stepId) -- 844
	if not canWriteStepLLMDebug(shared, stepId) then -- 844
		return 0 -- 845
	end -- 845
	local dir = getStepLLMDebugDir(shared) -- 846
	if not Content:exist(dir) or not Content:isdir(dir) then -- 846
		return 0 -- 847
	end -- 847
	local latest = 0 -- 848
	for ____, file in ipairs(Content:getFiles(dir)) do -- 849
		do -- 849
			local name = Path:getFilename(file) -- 850
			local seqText = string.match( -- 851
				name, -- 851
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 851
			) -- 851
			if seqText ~= nil then -- 851
				latest = math.max( -- 853
					latest, -- 853
					tonumber(seqText) -- 853
				) -- 853
				goto __continue120 -- 854
			end -- 854
			local legacyMatch = string.match( -- 856
				name, -- 856
				("^" .. tostring(stepId)) .. "_in%.md$" -- 856
			) -- 856
			if legacyMatch ~= nil then -- 856
				latest = math.max(latest, 1) -- 858
			end -- 858
		end -- 858
		::__continue120:: -- 858
	end -- 858
	return latest -- 861
end -- 844
local function writeStepLLMDebugFile(path, content) -- 864
	if not Content:save(path, content) then -- 864
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 866
		return false -- 867
	end -- 867
	return true -- 869
end -- 864
local function createStepLLMDebugPair(shared, stepId, inContent) -- 872
	if not canWriteStepLLMDebug(shared, stepId) then -- 872
		return 0 -- 873
	end -- 873
	local dir = getStepLLMDebugDir(shared) -- 874
	if not ensureDirRecursive(dir) then -- 874
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 876
		return 0 -- 877
	end -- 877
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 879
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 880
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 881
	if not writeStepLLMDebugFile(inPath, inContent) then -- 881
		return 0 -- 883
	end -- 883
	writeStepLLMDebugFile(outPath, "") -- 885
	return seq -- 886
end -- 872
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 889
	if not canWriteStepLLMDebug(shared, stepId) then -- 889
		return -- 890
	end -- 890
	local dir = getStepLLMDebugDir(shared) -- 891
	if not ensureDirRecursive(dir) then -- 891
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 893
		return -- 894
	end -- 894
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 896
	if latestSeq <= 0 then -- 896
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 898
		writeStepLLMDebugFile(outPath, content) -- 899
		return -- 900
	end -- 900
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 902
	writeStepLLMDebugFile(outPath, content) -- 903
end -- 889
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 906
	if not canWriteStepLLMDebug(shared, stepId) then -- 906
		return -- 907
	end -- 907
	local sections = { -- 908
		"# LLM Input", -- 909
		"session_id: " .. tostring(shared.sessionId), -- 910
		"task_id: " .. tostring(shared.taskId), -- 911
		"step_id: " .. tostring(stepId), -- 912
		"phase: " .. phase, -- 913
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 914
		"## Options", -- 915
		"```json", -- 916
		encodeDebugJSON(options), -- 917
		"```" -- 918
	} -- 918
	do -- 918
		local i = 0 -- 920
		while i < #messages do -- 920
			local message = messages[i + 1] -- 921
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 922
			sections[#sections + 1] = encodeDebugJSON(message) -- 923
			i = i + 1 -- 920
		end -- 920
	end -- 920
	createStepLLMDebugPair( -- 925
		shared, -- 925
		stepId, -- 925
		table.concat(sections, "\n") -- 925
	) -- 925
end -- 906
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 928
	if not canWriteStepLLMDebug(shared, stepId) then -- 928
		return -- 929
	end -- 929
	local ____array_2 = __TS__SparseArrayNew( -- 929
		"# LLM Output", -- 931
		"session_id: " .. tostring(shared.sessionId), -- 932
		"task_id: " .. tostring(shared.taskId), -- 933
		"step_id: " .. tostring(stepId), -- 934
		"phase: " .. phase, -- 935
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 936
		table.unpack(meta and ({ -- 937
			"## Meta", -- 937
			"```json", -- 937
			encodeDebugJSON(meta), -- 937
			"```" -- 937
		}) or ({})) -- 937
	) -- 937
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 937
	local sections = {__TS__SparseArraySpread(____array_2)} -- 930
	updateLatestStepLLMDebugOutput( -- 941
		shared, -- 941
		stepId, -- 941
		table.concat(sections, "\n") -- 941
	) -- 941
end -- 928
local function toJson(value) -- 944
	local text, err = safeJsonEncode(value) -- 945
	if text ~= nil then -- 945
		return text -- 946
	end -- 946
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 947
end -- 944
local function utf8TakeHead(text, maxChars) -- 957
	if maxChars <= 0 or text == "" then -- 957
		return "" -- 958
	end -- 958
	local nextPos = utf8.offset(text, maxChars + 1) -- 959
	if nextPos == nil then -- 959
		return text -- 960
	end -- 960
	return string.sub(text, 1, nextPos - 1) -- 961
end -- 957
local function limitReadContentForHistory(content, tool) -- 978
	local lines = __TS__StringSplit(content, "\n") -- 979
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 980
	local limitedByLines = overLineLimit and table.concat( -- 981
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 982
		"\n" -- 982
	) or content -- 982
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 982
		return content -- 985
	end -- 985
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 987
	local reasons = {} -- 990
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 990
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 991
	end -- 991
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 991
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 992
	end -- 992
	local hint = "Narrow the requested line range." -- 993
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 994
end -- 978
local function summarizeEditTextParamForHistory(value, key) -- 997
	if type(value) ~= "string" then -- 997
		return nil -- 998
	end -- 998
	local text = value -- 999
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1000
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1001
end -- 997
local function sanitizeReadResultForHistory(tool, result) -- 1009
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1009
		return result -- 1011
	end -- 1011
	local clone = {} -- 1013
	for key in pairs(result) do -- 1014
		clone[key] = result[key] -- 1015
	end -- 1015
	clone.content = limitReadContentForHistory(result.content, tool) -- 1017
	return clone -- 1018
end -- 1009
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1021
	local shown = math.min(#items, maxItems) -- 1025
	local out = {} -- 1026
	do -- 1026
		local i = 0 -- 1027
		while i < shown do -- 1027
			local row = items[i + 1] -- 1028
			out[#out + 1] = { -- 1029
				file = row.file, -- 1030
				line = row.line, -- 1031
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1032
			} -- 1032
			i = i + 1 -- 1027
		end -- 1027
	end -- 1027
	return out -- 1037
end -- 1021
local function sanitizeSearchResultForHistory(tool, result) -- 1040
	if result.success ~= true or not isArray(result.results) then -- 1040
		return result -- 1044
	end -- 1044
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1044
		return result -- 1045
	end -- 1045
	local clone = {} -- 1046
	for key in pairs(result) do -- 1047
		clone[key] = result[key] -- 1048
	end -- 1048
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1050
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1051
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1051
		local grouped = result.groupedResults -- 1056
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1057
		local sanitizedGroups = {} -- 1058
		do -- 1058
			local i = 0 -- 1059
			while i < shown do -- 1059
				local row = grouped[i + 1] -- 1060
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1061
					file = row.file, -- 1062
					totalMatches = row.totalMatches, -- 1063
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1064
				} -- 1064
				i = i + 1 -- 1059
			end -- 1059
		end -- 1059
		clone.groupedResults = sanitizedGroups -- 1069
	end -- 1069
	return clone -- 1071
end -- 1040
local function sanitizeListFilesResultForHistory(result) -- 1074
	if result.success ~= true or not isArray(result.files) then -- 1074
		return result -- 1075
	end -- 1075
	local clone = {} -- 1076
	for key in pairs(result) do -- 1077
		clone[key] = result[key] -- 1078
	end -- 1078
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1080
	return clone -- 1081
end -- 1074
local function sanitizeActionParamsForHistory(tool, params) -- 1084
	if tool ~= "edit_file" then -- 1084
		return params -- 1085
	end -- 1085
	local clone = {} -- 1086
	for key in pairs(params) do -- 1087
		if key == "old_str" then -- 1087
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1089
		elseif key == "new_str" then -- 1089
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1091
		else -- 1091
			clone[key] = params[key] -- 1093
		end -- 1093
	end -- 1093
	return clone -- 1096
end -- 1084
local function isToolAllowedForRole(role, tool) -- 1140
	return __TS__ArrayIndexOf( -- 1141
		getAllowedToolsForRole(role), -- 1141
		tool -- 1141
	) >= 0 -- 1141
end -- 1140
local function maybeCompressHistory(shared) -- 1144
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1144
		local ____shared_9 = shared -- 1145
		local memory = ____shared_9.memory -- 1145
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1146
		local changed = false -- 1147
		do -- 1147
			local round = 0 -- 1148
			while round < maxRounds do -- 1148
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1149
				local activeMessages = getActiveConversationMessages(shared) -- 1150
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1154
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1154
					if changed then -- 1154
						persistHistoryState(shared) -- 1163
					end -- 1163
					return ____awaiter_resolve(nil) -- 1163
				end -- 1163
				local compressionRound = round + 1 -- 1167
				shared.step = shared.step + 1 -- 1168
				local stepId = shared.step -- 1169
				local pendingMessages = #activeMessages -- 1170
				emitAgentEvent( -- 1171
					shared, -- 1171
					{ -- 1171
						type = "memory_compression_started", -- 1172
						sessionId = shared.sessionId, -- 1173
						taskId = shared.taskId, -- 1174
						step = stepId, -- 1175
						tool = "compress_memory", -- 1176
						reason = getMemoryCompressionStartReason(shared), -- 1177
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1178
					} -- 1178
				) -- 1178
				local result = __TS__Await(memory.compressor:compress( -- 1184
					activeMessages, -- 1185
					shared.llmOptions, -- 1186
					shared.llmMaxTry, -- 1187
					shared.decisionMode, -- 1188
					{ -- 1189
						onInput = function(____, phase, messages, options) -- 1190
							saveStepLLMDebugInput( -- 1191
								shared, -- 1191
								stepId, -- 1191
								phase, -- 1191
								messages, -- 1191
								options -- 1191
							) -- 1191
						end, -- 1190
						onOutput = function(____, phase, text, meta) -- 1193
							saveStepLLMDebugOutput( -- 1194
								shared, -- 1194
								stepId, -- 1194
								phase, -- 1194
								text, -- 1194
								meta -- 1194
							) -- 1194
						end -- 1193
					}, -- 1193
					"default", -- 1197
					systemPrompt, -- 1198
					toolDefinitions -- 1199
				)) -- 1199
				if not (result and result.success and result.compressedCount > 0) then -- 1199
					emitAgentEvent( -- 1202
						shared, -- 1202
						{ -- 1202
							type = "memory_compression_finished", -- 1203
							sessionId = shared.sessionId, -- 1204
							taskId = shared.taskId, -- 1205
							step = stepId, -- 1206
							tool = "compress_memory", -- 1207
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1208
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1212
						} -- 1212
					) -- 1212
					if changed then -- 1212
						persistHistoryState(shared) -- 1220
					end -- 1220
					return ____awaiter_resolve(nil) -- 1220
				end -- 1220
				local effectiveCompressedCount = math.max( -- 1224
					0, -- 1225
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1226
				) -- 1226
				if effectiveCompressedCount <= 0 then -- 1226
					if changed then -- 1226
						persistHistoryState(shared) -- 1230
					end -- 1230
					return ____awaiter_resolve(nil) -- 1230
				end -- 1230
				emitAgentEvent( -- 1234
					shared, -- 1234
					{ -- 1234
						type = "memory_compression_finished", -- 1235
						sessionId = shared.sessionId, -- 1236
						taskId = shared.taskId, -- 1237
						step = stepId, -- 1238
						tool = "compress_memory", -- 1239
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1240
						result = { -- 1241
							success = true, -- 1242
							round = compressionRound, -- 1243
							compressedCount = effectiveCompressedCount, -- 1244
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1245
						} -- 1245
					} -- 1245
				) -- 1245
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1248
				changed = true -- 1249
				Log( -- 1250
					"Info", -- 1250
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1250
				) -- 1250
				round = round + 1 -- 1148
			end -- 1148
		end -- 1148
		if changed then -- 1148
			persistHistoryState(shared) -- 1253
		end -- 1253
	end) -- 1253
end -- 1144
local function compactAllHistory(shared) -- 1257
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1257
		local ____shared_16 = shared -- 1258
		local memory = ____shared_16.memory -- 1258
		local rounds = 0 -- 1259
		local totalCompressed = 0 -- 1260
		while getActiveRealMessageCount(shared) > 0 do -- 1260
			if shared.stopToken.stopped then -- 1260
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1263
				return ____awaiter_resolve( -- 1263
					nil, -- 1263
					emitAgentTaskFinishEvent( -- 1264
						shared, -- 1264
						false, -- 1264
						getCancelledReason(shared) -- 1264
					) -- 1264
				) -- 1264
			end -- 1264
			rounds = rounds + 1 -- 1266
			shared.step = shared.step + 1 -- 1267
			local stepId = shared.step -- 1268
			local activeMessages = getActiveConversationMessages(shared) -- 1269
			local pendingMessages = #activeMessages -- 1270
			emitAgentEvent( -- 1271
				shared, -- 1271
				{ -- 1271
					type = "memory_compression_started", -- 1272
					sessionId = shared.sessionId, -- 1273
					taskId = shared.taskId, -- 1274
					step = stepId, -- 1275
					tool = "compress_memory", -- 1276
					reason = getMemoryCompressionStartReason(shared), -- 1277
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1278
				} -- 1278
			) -- 1278
			local result = __TS__Await(memory.compressor:compress( -- 1285
				activeMessages, -- 1286
				shared.llmOptions, -- 1287
				shared.llmMaxTry, -- 1288
				shared.decisionMode, -- 1289
				{ -- 1290
					onInput = function(____, phase, messages, options) -- 1291
						saveStepLLMDebugInput( -- 1292
							shared, -- 1292
							stepId, -- 1292
							phase, -- 1292
							messages, -- 1292
							options -- 1292
						) -- 1292
					end, -- 1291
					onOutput = function(____, phase, text, meta) -- 1294
						saveStepLLMDebugOutput( -- 1295
							shared, -- 1295
							stepId, -- 1295
							phase, -- 1295
							text, -- 1295
							meta -- 1295
						) -- 1295
					end -- 1294
				}, -- 1294
				"budget_max" -- 1298
			)) -- 1298
			if not (result and result.success and result.compressedCount > 0) then -- 1298
				emitAgentEvent( -- 1301
					shared, -- 1301
					{ -- 1301
						type = "memory_compression_finished", -- 1302
						sessionId = shared.sessionId, -- 1303
						taskId = shared.taskId, -- 1304
						step = stepId, -- 1305
						tool = "compress_memory", -- 1306
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1307
						result = { -- 1311
							success = false, -- 1312
							rounds = rounds, -- 1313
							error = result and result.error or "compression returned no changes", -- 1314
							compressedCount = result and result.compressedCount or 0, -- 1315
							fullCompaction = true -- 1316
						} -- 1316
					} -- 1316
				) -- 1316
				return ____awaiter_resolve( -- 1316
					nil, -- 1316
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1319
				) -- 1319
			end -- 1319
			local effectiveCompressedCount = math.max( -- 1324
				0, -- 1325
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1326
			) -- 1326
			if effectiveCompressedCount <= 0 then -- 1326
				return ____awaiter_resolve( -- 1326
					nil, -- 1326
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1329
				) -- 1329
			end -- 1329
			emitAgentEvent( -- 1336
				shared, -- 1336
				{ -- 1336
					type = "memory_compression_finished", -- 1337
					sessionId = shared.sessionId, -- 1338
					taskId = shared.taskId, -- 1339
					step = stepId, -- 1340
					tool = "compress_memory", -- 1341
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1342
					result = { -- 1343
						success = true, -- 1344
						round = rounds, -- 1345
						compressedCount = effectiveCompressedCount, -- 1346
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1347
						fullCompaction = true -- 1348
					} -- 1348
				} -- 1348
			) -- 1348
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1351
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1352
			persistHistoryState(shared) -- 1353
			Log( -- 1354
				"Info", -- 1354
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1354
			) -- 1354
		end -- 1354
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1356
		return ____awaiter_resolve( -- 1356
			nil, -- 1356
			emitAgentTaskFinishEvent( -- 1357
				shared, -- 1358
				true, -- 1359
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1360
			) -- 1360
		) -- 1360
	end) -- 1360
end -- 1257
local function resetSessionHistory(shared) -- 1366
	shared.messages = {} -- 1367
	shared.lastConsolidatedIndex = 0 -- 1368
	shared.carryMessageIndex = nil -- 1369
	persistHistoryState(shared) -- 1370
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1371
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1372
end -- 1366
local function isKnownToolName(name) -- 1381
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1382
end -- 1381
local function getFinishMessage(params, fallback) -- 1394
	if fallback == nil then -- 1394
		fallback = "" -- 1394
	end -- 1394
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1394
		return __TS__StringTrim(params.message) -- 1396
	end -- 1396
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1396
		return __TS__StringTrim(params.response) -- 1399
	end -- 1399
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1399
		return __TS__StringTrim(params.summary) -- 1402
	end -- 1402
	return __TS__StringTrim(fallback) -- 1404
end -- 1394
local function appendConversationMessage(shared, message) -- 1475
	local ____shared_messages_25 = shared.messages -- 1475
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1476
		{}, -- 1476
		message, -- 1477
		{ -- 1476
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1478
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1479
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1480
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1481
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1482
		} -- 1482
	) -- 1482
end -- 1475
local function ensureToolCallId(toolCallId) -- 1486
	if toolCallId and toolCallId ~= "" then -- 1486
		return toolCallId -- 1487
	end -- 1487
	return createLocalToolCallId() -- 1488
end -- 1486
local function appendToolResultMessage(shared, action) -- 1491
	appendConversationMessage( -- 1492
		shared, -- 1492
		{ -- 1492
			role = "tool", -- 1493
			tool_call_id = action.toolCallId, -- 1494
			name = action.tool, -- 1495
			content = action.result and toJson(action.result) or "" -- 1496
		} -- 1496
	) -- 1496
end -- 1491
local function parseXMLToolCallObjectFromText(text) -- 1500
	local children = parseXMLObjectFromText(text, "tool_call") -- 1501
	if not children.success then -- 1501
		return children -- 1502
	end -- 1502
	local rawObj = children.obj -- 1503
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1504
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1505
	if not params.success then -- 1505
		return {success = false, message = params.message} -- 1509
	end -- 1509
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1511
end -- 1500
local function llm(shared, messages, phase) -- 1530
	if phase == nil then -- 1530
		phase = "decision_xml" -- 1533
	end -- 1533
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1533
		local stepId = shared.step + 1 -- 1535
		saveStepLLMDebugInput( -- 1536
			shared, -- 1536
			stepId, -- 1536
			phase, -- 1536
			messages, -- 1536
			shared.llmOptions -- 1536
		) -- 1536
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1537
		if res.success then -- 1537
			local ____opt_30 = res.response.choices -- 1537
			local ____opt_28 = ____opt_30 and ____opt_30[1] -- 1537
			local ____opt_26 = ____opt_28 and ____opt_28.message -- 1537
			local text = ____opt_26 and ____opt_26.content -- 1539
			if text then -- 1539
				saveStepLLMDebugOutput( -- 1541
					shared, -- 1541
					stepId, -- 1541
					phase, -- 1541
					text, -- 1541
					{success = true} -- 1541
				) -- 1541
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 1541
			else -- 1541
				saveStepLLMDebugOutput( -- 1544
					shared, -- 1544
					stepId, -- 1544
					phase, -- 1544
					"empty LLM response", -- 1544
					{success = false} -- 1544
				) -- 1544
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1544
			end -- 1544
		else -- 1544
			saveStepLLMDebugOutput( -- 1548
				shared, -- 1548
				stepId, -- 1548
				phase, -- 1548
				res.raw or res.message, -- 1548
				{success = false} -- 1548
			) -- 1548
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1548
		end -- 1548
	end) -- 1548
end -- 1530
local function parseDecisionObject(rawObj) -- 1565
	if type(rawObj.tool) ~= "string" then -- 1565
		return {success = false, message = "missing tool"} -- 1566
	end -- 1566
	local tool = rawObj.tool -- 1567
	if not isKnownToolName(tool) then -- 1567
		return {success = false, message = "unknown tool: " .. tool} -- 1569
	end -- 1569
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1571
	if tool ~= "finish" and (not reason or reason == "") then -- 1571
		return {success = false, message = tool .. " requires top-level reason"} -- 1575
	end -- 1575
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1577
	return {success = true, tool = tool, params = params, reason = reason} -- 1578
end -- 1565
local function parseDecisionToolCall(functionName, rawObj) -- 1586
	if not isKnownToolName(functionName) then -- 1586
		return {success = false, message = "unknown tool: " .. functionName} -- 1588
	end -- 1588
	if rawObj == nil or rawObj == nil then -- 1588
		return {success = true, tool = functionName, params = {}} -- 1591
	end -- 1591
	if not isRecord(rawObj) then -- 1591
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1594
	end -- 1594
	return {success = true, tool = functionName, params = rawObj} -- 1596
end -- 1586
local function getDecisionPath(params) -- 1603
	if type(params.path) == "string" then -- 1603
		return __TS__StringTrim(params.path) -- 1604
	end -- 1604
	if type(params.target_file) == "string" then -- 1604
		return __TS__StringTrim(params.target_file) -- 1605
	end -- 1605
	return "" -- 1606
end -- 1603
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1609
	local num = __TS__Number(value) -- 1610
	if not __TS__NumberIsFinite(num) then -- 1610
		num = fallback -- 1611
	end -- 1611
	num = math.floor(num) -- 1612
	if num < minValue then -- 1612
		num = minValue -- 1613
	end -- 1613
	if maxValue ~= nil and num > maxValue then -- 1613
		num = maxValue -- 1614
	end -- 1614
	return num -- 1615
end -- 1609
local function parseReadLineParam(value, fallback, paramName) -- 1618
	local num = __TS__Number(value) -- 1623
	if not __TS__NumberIsFinite(num) then -- 1623
		num = fallback -- 1624
	end -- 1624
	num = math.floor(num) -- 1625
	if num == 0 then -- 1625
		return {success = false, message = paramName .. " cannot be 0"} -- 1627
	end -- 1627
	return {success = true, value = num} -- 1629
end -- 1618
local function validateDecision(tool, params) -- 1632
	if tool == "finish" then -- 1632
		local message = getFinishMessage(params) -- 1637
		if message == "" then -- 1637
			return {success = false, message = "finish requires params.message"} -- 1638
		end -- 1638
		params.message = message -- 1639
		return {success = true, params = params} -- 1640
	end -- 1640
	if tool == "read_file" then -- 1640
		local path = getDecisionPath(params) -- 1644
		if path == "" then -- 1644
			return {success = false, message = "read_file requires path"} -- 1645
		end -- 1645
		params.path = path -- 1646
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1647
		if not startLineRes.success then -- 1647
			return startLineRes -- 1648
		end -- 1648
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1649
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1650
		if not endLineRes.success then -- 1650
			return endLineRes -- 1651
		end -- 1651
		params.startLine = startLineRes.value -- 1652
		params.endLine = endLineRes.value -- 1653
		return {success = true, params = params} -- 1654
	end -- 1654
	if tool == "edit_file" then -- 1654
		local path = getDecisionPath(params) -- 1658
		if path == "" then -- 1658
			return {success = false, message = "edit_file requires path"} -- 1659
		end -- 1659
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1660
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1661
		params.path = path -- 1662
		params.old_str = oldStr -- 1663
		params.new_str = newStr -- 1664
		return {success = true, params = params} -- 1665
	end -- 1665
	if tool == "delete_file" then -- 1665
		local targetFile = getDecisionPath(params) -- 1669
		if targetFile == "" then -- 1669
			return {success = false, message = "delete_file requires target_file"} -- 1670
		end -- 1670
		params.target_file = targetFile -- 1671
		return {success = true, params = params} -- 1672
	end -- 1672
	if tool == "grep_files" then -- 1672
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1676
		if pattern == "" then -- 1676
			return {success = false, message = "grep_files requires pattern"} -- 1677
		end -- 1677
		params.pattern = pattern -- 1678
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1679
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1680
		return {success = true, params = params} -- 1681
	end -- 1681
	if tool == "search_dora_api" then -- 1681
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1685
		if pattern == "" then -- 1685
			return {success = false, message = "search_dora_api requires pattern"} -- 1686
		end -- 1686
		params.pattern = pattern -- 1687
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1688
		return {success = true, params = params} -- 1689
	end -- 1689
	if tool == "glob_files" then -- 1689
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1693
		return {success = true, params = params} -- 1694
	end -- 1694
	if tool == "build" then -- 1694
		local path = getDecisionPath(params) -- 1698
		if path ~= "" then -- 1698
			params.path = path -- 1700
		end -- 1700
		return {success = true, params = params} -- 1702
	end -- 1702
	if tool == "list_sub_agents" then -- 1702
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1706
		if status ~= "" then -- 1706
			params.status = status -- 1708
		end -- 1708
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1710
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1711
		if type(params.query) == "string" then -- 1711
			params.query = __TS__StringTrim(params.query) -- 1713
		end -- 1713
		return {success = true, params = params} -- 1715
	end -- 1715
	if tool == "spawn_sub_agent" then -- 1715
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1719
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1720
		if prompt == "" then -- 1720
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1721
		end -- 1721
		if title == "" then -- 1721
			return {success = false, message = "spawn_sub_agent requires title"} -- 1722
		end -- 1722
		params.prompt = prompt -- 1723
		params.title = title -- 1724
		if type(params.expectedOutput) == "string" then -- 1724
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1726
		end -- 1726
		if isArray(params.filesHint) then -- 1726
			params.filesHint = __TS__ArrayMap( -- 1729
				__TS__ArrayFilter( -- 1729
					params.filesHint, -- 1729
					function(____, item) return type(item) == "string" end -- 1730
				), -- 1730
				function(____, item) return sanitizeUTF8(item) end -- 1731
			) -- 1731
		end -- 1731
		return {success = true, params = params} -- 1733
	end -- 1733
	return {success = true, params = params} -- 1736
end -- 1632
local function createFunctionToolSchema(name, description, properties, required) -- 1739
	if required == nil then -- 1739
		required = {} -- 1743
	end -- 1743
	local parameters = {type = "object", properties = properties} -- 1745
	if #required > 0 then -- 1745
		parameters.required = required -- 1750
	end -- 1750
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1752
end -- 1739
local function buildDecisionToolSchema(shared) -- 1768
	local allowed = getAllowedToolsForRole(shared.role) -- 1769
	local tools = { -- 1770
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1771
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1781
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1791
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1799
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1803
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1804
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1805
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1806
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1807
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1808
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1809
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1810
		}, {"pattern"}), -- 1810
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1814
		createFunctionToolSchema( -- 1823
			"search_dora_api", -- 1824
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1824
			{ -- 1826
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1827
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1828
				programmingLanguage = {type = "string", enum = { -- 1829
					"ts", -- 1831
					"tsx", -- 1831
					"lua", -- 1831
					"yue", -- 1831
					"teal", -- 1831
					"tl", -- 1831
					"wa" -- 1831
				}, description = "Preferred language variant to search."}, -- 1831
				limit = { -- 1834
					type = "number", -- 1834
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1834
				}, -- 1834
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1835
			}, -- 1835
			{"pattern"} -- 1837
		), -- 1837
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1839
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 1846
			"active_or_recent", -- 1850
			"running", -- 1850
			"done", -- 1850
			"failed", -- 1850
			"all" -- 1850
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 1850
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute concrete work. Use this when the task moves from discussion/search into coding, file editing, file deletion, build verification, documentation writing, or other execution-heavy work. The sub agent has the full execution toolset including edit_file, delete_file, and build. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1856
	} -- 1856
	return __TS__ArrayFilter( -- 1868
		tools, -- 1868
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1868
	) -- 1868
end -- 1768
local function sanitizeMessagesForLLMInput(messages) -- 1926
	local sanitized = {} -- 1927
	local droppedAssistantToolCalls = 0 -- 1928
	local droppedToolResults = 0 -- 1929
	do -- 1929
		local i = 0 -- 1930
		while i < #messages do -- 1930
			do -- 1930
				local message = messages[i + 1] -- 1931
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1931
					local requiredIds = {} -- 1933
					do -- 1933
						local j = 0 -- 1934
						while j < #message.tool_calls do -- 1934
							local toolCall = message.tool_calls[j + 1] -- 1935
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1936
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1936
								requiredIds[#requiredIds + 1] = id -- 1938
							end -- 1938
							j = j + 1 -- 1934
						end -- 1934
					end -- 1934
					if #requiredIds == 0 then -- 1934
						sanitized[#sanitized + 1] = message -- 1942
						goto __continue296 -- 1943
					end -- 1943
					local matchedIds = {} -- 1945
					local matchedTools = {} -- 1946
					local j = i + 1 -- 1947
					while j < #messages do -- 1947
						local toolMessage = messages[j + 1] -- 1949
						if toolMessage.role ~= "tool" then -- 1949
							break -- 1950
						end -- 1950
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1951
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1951
							matchedIds[toolCallId] = true -- 1953
							matchedTools[#matchedTools + 1] = toolMessage -- 1954
						else -- 1954
							droppedToolResults = droppedToolResults + 1 -- 1956
						end -- 1956
						j = j + 1 -- 1958
					end -- 1958
					local complete = true -- 1960
					do -- 1960
						local j = 0 -- 1961
						while j < #requiredIds do -- 1961
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1961
								complete = false -- 1963
								break -- 1964
							end -- 1964
							j = j + 1 -- 1961
						end -- 1961
					end -- 1961
					if complete then -- 1961
						__TS__ArrayPush( -- 1968
							sanitized, -- 1968
							message, -- 1968
							table.unpack(matchedTools) -- 1968
						) -- 1968
					else -- 1968
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1970
						droppedToolResults = droppedToolResults + #matchedTools -- 1971
					end -- 1971
					i = j - 1 -- 1973
					goto __continue296 -- 1974
				end -- 1974
				if message.role == "tool" then -- 1974
					droppedToolResults = droppedToolResults + 1 -- 1977
					goto __continue296 -- 1978
				end -- 1978
				sanitized[#sanitized + 1] = message -- 1980
			end -- 1980
			::__continue296:: -- 1980
			i = i + 1 -- 1930
		end -- 1930
	end -- 1930
	return sanitized -- 1982
end -- 1926
local function getUnconsolidatedMessages(shared) -- 1985
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1986
end -- 1985
local function getFinalDecisionTurnPrompt(shared) -- 1989
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1990
end -- 1989
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1995
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1995
		return messages -- 1996
	end -- 1996
	local next = __TS__ArrayMap( -- 1997
		messages, -- 1997
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1997
	) -- 1997
	do -- 1997
		local i = #next - 1 -- 1998
		while i >= 0 do -- 1998
			do -- 1998
				local message = next[i + 1] -- 1999
				if message.role ~= "assistant" and message.role ~= "user" then -- 1999
					goto __continue318 -- 2000
				end -- 2000
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2001
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2002
				return next -- 2005
			end -- 2005
			::__continue318:: -- 2005
			i = i - 1 -- 1998
		end -- 1998
	end -- 1998
	next[#next + 1] = {role = "user", content = prompt} -- 2007
	return next -- 2008
end -- 1995
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2011
	if attempt == nil then -- 2011
		attempt = 1 -- 2011
	end -- 2011
	local messages = { -- 2012
		{ -- 2013
			role = "system", -- 2013
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2013
		}, -- 2013
		table.unpack(getUnconsolidatedMessages(shared)) -- 2014
	} -- 2014
	if shared.step + 1 >= shared.maxSteps then -- 2014
		messages = appendPromptToLatestDecisionMessage( -- 2017
			messages, -- 2017
			getFinalDecisionTurnPrompt(shared) -- 2017
		) -- 2017
	end -- 2017
	if lastError and lastError ~= "" then -- 2017
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2020
		messages[#messages + 1] = { -- 2023
			role = "user", -- 2024
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2025
		} -- 2025
	end -- 2025
	return messages -- 2032
end -- 2011
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2039
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2046
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2047
	local repairPrompt = replacePromptVars( -- 2055
		shared.promptPack.xmlDecisionRepairPrompt, -- 2055
		{ -- 2055
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2056
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2057
			CANDIDATE_SECTION = candidateSection, -- 2058
			LAST_ERROR = lastError, -- 2059
			ATTEMPT = tostring(attempt) -- 2060
		} -- 2060
	) -- 2060
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2062
end -- 2039
local function tryParseAndValidateDecision(rawText) -- 2074
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2075
	if not parsed.success then -- 2075
		return {success = false, message = parsed.message, raw = rawText} -- 2077
	end -- 2077
	local decision = parseDecisionObject(parsed.obj) -- 2079
	if not decision.success then -- 2079
		return {success = false, message = decision.message, raw = rawText} -- 2081
	end -- 2081
	local validation = validateDecision(decision.tool, decision.params) -- 2083
	if not validation.success then -- 2083
		return {success = false, message = validation.message, raw = rawText} -- 2085
	end -- 2085
	decision.params = validation.params -- 2087
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2088
	return decision -- 2089
end -- 2074
local function normalizeLineEndings(text) -- 2092
	local res = string.gsub(text, "\r\n", "\n") -- 2093
	res = string.gsub(res, "\r", "\n") -- 2094
	return res -- 2095
end -- 2092
local function countOccurrences(text, searchStr) -- 2098
	if searchStr == "" then -- 2098
		return 0 -- 2099
	end -- 2099
	local count = 0 -- 2100
	local pos = 0 -- 2101
	while true do -- 2101
		local idx = (string.find( -- 2103
			text, -- 2103
			searchStr, -- 2103
			math.max(pos + 1, 1), -- 2103
			true -- 2103
		) or 0) - 1 -- 2103
		if idx < 0 then -- 2103
			break -- 2104
		end -- 2104
		count = count + 1 -- 2105
		pos = idx + #searchStr -- 2106
	end -- 2106
	return count -- 2108
end -- 2098
local function replaceFirst(text, oldStr, newStr) -- 2111
	if oldStr == "" then -- 2111
		return text -- 2112
	end -- 2112
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2113
	if idx < 0 then -- 2113
		return text -- 2114
	end -- 2114
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2115
end -- 2111
local function splitLines(text) -- 2118
	return __TS__StringSplit(text, "\n") -- 2119
end -- 2118
local function getLeadingWhitespace(text) -- 2122
	local i = 0 -- 2123
	while i < #text do -- 2123
		local ch = __TS__StringAccess(text, i) -- 2125
		if ch ~= " " and ch ~= "\t" then -- 2125
			break -- 2126
		end -- 2126
		i = i + 1 -- 2127
	end -- 2127
	return __TS__StringSubstring(text, 0, i) -- 2129
end -- 2122
local function getCommonIndentPrefix(lines) -- 2132
	local common -- 2133
	do -- 2133
		local i = 0 -- 2134
		while i < #lines do -- 2134
			do -- 2134
				local line = lines[i + 1] -- 2135
				if __TS__StringTrim(line) == "" then -- 2135
					goto __continue343 -- 2136
				end -- 2136
				local indent = getLeadingWhitespace(line) -- 2137
				if common == nil then -- 2137
					common = indent -- 2139
					goto __continue343 -- 2140
				end -- 2140
				local j = 0 -- 2142
				local maxLen = math.min(#common, #indent) -- 2143
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2143
					j = j + 1 -- 2145
				end -- 2145
				common = __TS__StringSubstring(common, 0, j) -- 2147
				if common == "" then -- 2147
					break -- 2148
				end -- 2148
			end -- 2148
			::__continue343:: -- 2148
			i = i + 1 -- 2134
		end -- 2134
	end -- 2134
	return common or "" -- 2150
end -- 2132
local function removeIndentPrefix(line, indent) -- 2153
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2153
		return __TS__StringSubstring(line, #indent) -- 2155
	end -- 2155
	local lineIndent = getLeadingWhitespace(line) -- 2157
	local j = 0 -- 2158
	local maxLen = math.min(#lineIndent, #indent) -- 2159
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2159
		j = j + 1 -- 2161
	end -- 2161
	return __TS__StringSubstring(line, j) -- 2163
end -- 2153
local function dedentLines(lines) -- 2166
	local indent = getCommonIndentPrefix(lines) -- 2167
	return { -- 2168
		indent = indent, -- 2169
		lines = __TS__ArrayMap( -- 2170
			lines, -- 2170
			function(____, line) return removeIndentPrefix(line, indent) end -- 2170
		) -- 2170
	} -- 2170
end -- 2166
local function joinLines(lines) -- 2174
	return table.concat(lines, "\n") -- 2175
end -- 2174
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2178
	local contentLines = splitLines(content) -- 2183
	local oldLines = splitLines(oldStr) -- 2184
	if #oldLines == 0 then -- 2184
		return {success = false, message = "old_str not found in file"} -- 2186
	end -- 2186
	local dedentedOld = dedentLines(oldLines) -- 2188
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2189
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2190
	local matches = {} -- 2191
	do -- 2191
		local start = 0 -- 2192
		while start <= #contentLines - #oldLines do -- 2192
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2193
			local dedentedCandidate = dedentLines(candidateLines) -- 2194
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2194
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2196
			end -- 2196
			start = start + 1 -- 2192
		end -- 2192
	end -- 2192
	if #matches == 0 then -- 2192
		return {success = false, message = "old_str not found in file"} -- 2204
	end -- 2204
	if #matches > 1 then -- 2204
		return { -- 2207
			success = false, -- 2208
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2209
		} -- 2209
	end -- 2209
	local match = matches[1] -- 2212
	local rebuiltNewLines = __TS__ArrayMap( -- 2213
		dedentedNew.lines, -- 2213
		function(____, line) return line == "" and "" or match.indent .. line end -- 2213
	) -- 2213
	local ____array_36 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2213
	__TS__SparseArrayPush( -- 2213
		____array_36, -- 2213
		table.unpack(rebuiltNewLines) -- 2216
	) -- 2216
	__TS__SparseArrayPush( -- 2216
		____array_36, -- 2216
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2217
	) -- 2217
	local nextLines = {__TS__SparseArraySpread(____array_36)} -- 2214
	return { -- 2219
		success = true, -- 2219
		content = joinLines(nextLines) -- 2219
	} -- 2219
end -- 2178
local MainDecisionAgent = __TS__Class() -- 2222
MainDecisionAgent.name = "MainDecisionAgent" -- 2222
__TS__ClassExtends(MainDecisionAgent, Node) -- 2222
function MainDecisionAgent.prototype.prep(self, shared) -- 2223
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2223
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2223
			return ____awaiter_resolve(nil, {shared = shared}) -- 2223
		end -- 2223
		__TS__Await(maybeCompressHistory(shared)) -- 2228
		return ____awaiter_resolve(nil, {shared = shared}) -- 2228
	end) -- 2228
end -- 2223
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2233
	if attempt == nil then -- 2233
		attempt = 1 -- 2236
	end -- 2236
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2236
		if shared.stopToken.stopped then -- 2236
			return ____awaiter_resolve( -- 2236
				nil, -- 2236
				{ -- 2240
					success = false, -- 2240
					message = getCancelledReason(shared) -- 2240
				} -- 2240
			) -- 2240
		end -- 2240
		Log( -- 2242
			"Info", -- 2242
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2242
		) -- 2242
		local tools = buildDecisionToolSchema(shared) -- 2243
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2244
		local stepId = shared.step + 1 -- 2245
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2246
		saveStepLLMDebugInput( -- 2250
			shared, -- 2250
			stepId, -- 2250
			"decision_tool_calling", -- 2250
			messages, -- 2250
			llmOptions -- 2250
		) -- 2250
		local lastStreamContent = "" -- 2251
		local lastStreamReasoning = "" -- 2252
		local res = __TS__Await(callLLMStreamAggregated( -- 2253
			messages, -- 2254
			llmOptions, -- 2255
			shared.stopToken, -- 2256
			shared.llmConfig, -- 2257
			function(response) -- 2258
				local ____opt_39 = response.choices -- 2258
				local ____opt_37 = ____opt_39 and ____opt_39[1] -- 2258
				local streamMessage = ____opt_37 and ____opt_37.message -- 2259
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2260
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2263
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2263
					return -- 2267
				end -- 2267
				lastStreamContent = nextContent -- 2269
				lastStreamReasoning = nextReasoning -- 2270
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2271
			end -- 2258
		)) -- 2258
		if shared.stopToken.stopped then -- 2258
			return ____awaiter_resolve( -- 2258
				nil, -- 2258
				{ -- 2275
					success = false, -- 2275
					message = getCancelledReason(shared) -- 2275
				} -- 2275
			) -- 2275
		end -- 2275
		if not res.success then -- 2275
			saveStepLLMDebugOutput( -- 2278
				shared, -- 2278
				stepId, -- 2278
				"decision_tool_calling", -- 2278
				res.raw or res.message, -- 2278
				{success = false} -- 2278
			) -- 2278
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2279
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2279
		end -- 2279
		saveStepLLMDebugOutput( -- 2282
			shared, -- 2282
			stepId, -- 2282
			"decision_tool_calling", -- 2282
			encodeDebugJSON(res.response), -- 2282
			{success = true} -- 2282
		) -- 2282
		local choice = res.response.choices and res.response.choices[1] -- 2283
		local message = choice and choice.message -- 2284
		local toolCalls = message and message.tool_calls -- 2285
		local toolCall = toolCalls and toolCalls[1] -- 2286
		local fn = toolCall and toolCall["function"] -- 2287
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2288
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 2291
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2294
		Log( -- 2297
			"Info", -- 2297
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2297
		) -- 2297
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2297
			if messageContent and messageContent ~= "" then -- 2297
				Log( -- 2300
					"Info", -- 2300
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2300
				) -- 2300
				return ____awaiter_resolve(nil, { -- 2300
					success = true, -- 2302
					tool = "finish", -- 2303
					params = {}, -- 2304
					reason = messageContent, -- 2305
					reasoningContent = reasoningContent, -- 2306
					directSummary = messageContent -- 2307
				}) -- 2307
			end -- 2307
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2310
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2310
		end -- 2310
		local functionName = fn.name -- 2317
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2318
		Log( -- 2319
			"Info", -- 2319
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2319
		) -- 2319
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2320
			local rawObj, err = safeJsonDecode(argsText) -- 2321
			if err ~= nil or rawObj == nil then -- 2321
				return {__error = tostring(err)} -- 2323
			end -- 2323
			return rawObj -- 2325
		end)() -- 2320
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2320
			local err = tostring(rawArgs.__error) -- 2328
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2329
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2329
		end -- 2329
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2336
		if not decision.success then -- 2336
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2338
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2338
		end -- 2338
		local validation = validateDecision(decision.tool, decision.params) -- 2345
		if not validation.success then -- 2345
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2347
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2347
		end -- 2347
		if not isToolAllowedForRole(shared.role, decision.tool) then -- 2347
			return ____awaiter_resolve(nil, {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText}) -- 2347
		end -- 2347
		decision.params = validation.params -- 2361
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2362
		decision.reason = messageContent -- 2363
		decision.reasoningContent = reasoningContent -- 2364
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2365
		return ____awaiter_resolve(nil, decision) -- 2365
	end) -- 2365
end -- 2233
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2369
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2369
		Log( -- 2374
			"Info", -- 2374
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2374
		) -- 2374
		local lastError = initialError -- 2375
		local candidateRaw = "" -- 2376
		do -- 2376
			local attempt = 0 -- 2377
			while attempt < shared.llmMaxTry do -- 2377
				do -- 2377
					Log( -- 2378
						"Info", -- 2378
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2378
					) -- 2378
					local messages = buildXmlRepairMessages( -- 2379
						shared, -- 2380
						originalRaw, -- 2381
						candidateRaw, -- 2382
						lastError, -- 2383
						attempt + 1 -- 2384
					) -- 2384
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2386
					if shared.stopToken.stopped then -- 2386
						return ____awaiter_resolve( -- 2386
							nil, -- 2386
							{ -- 2388
								success = false, -- 2388
								message = getCancelledReason(shared) -- 2388
							} -- 2388
						) -- 2388
					end -- 2388
					if not llmRes.success then -- 2388
						lastError = llmRes.message -- 2391
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2392
						goto __continue380 -- 2393
					end -- 2393
					candidateRaw = llmRes.text -- 2395
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2396
					if decision.success then -- 2396
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2398
						return ____awaiter_resolve(nil, decision) -- 2398
					end -- 2398
					lastError = decision.message -- 2401
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2402
				end -- 2402
				::__continue380:: -- 2402
				attempt = attempt + 1 -- 2377
			end -- 2377
		end -- 2377
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2404
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2404
	end) -- 2404
end -- 2369
function MainDecisionAgent.prototype.exec(self, input) -- 2412
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2412
		local shared = input.shared -- 2413
		if shared.stopToken.stopped then -- 2413
			return ____awaiter_resolve( -- 2413
				nil, -- 2413
				{ -- 2415
					success = false, -- 2415
					message = getCancelledReason(shared) -- 2415
				} -- 2415
			) -- 2415
		end -- 2415
		if shared.step >= shared.maxSteps then -- 2415
			Log( -- 2418
				"Warn", -- 2418
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2418
			) -- 2418
			return ____awaiter_resolve( -- 2418
				nil, -- 2418
				{ -- 2419
					success = false, -- 2419
					message = getMaxStepsReachedReason(shared) -- 2419
				} -- 2419
			) -- 2419
		end -- 2419
		if shared.decisionMode == "tool_calling" then -- 2419
			Log( -- 2423
				"Info", -- 2423
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2423
			) -- 2423
			local lastError = "tool calling validation failed" -- 2424
			local lastRaw = "" -- 2425
			do -- 2425
				local attempt = 0 -- 2426
				while attempt < shared.llmMaxTry do -- 2426
					Log( -- 2427
						"Info", -- 2427
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2427
					) -- 2427
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2428
					if shared.stopToken.stopped then -- 2428
						return ____awaiter_resolve( -- 2428
							nil, -- 2428
							{ -- 2435
								success = false, -- 2435
								message = getCancelledReason(shared) -- 2435
							} -- 2435
						) -- 2435
					end -- 2435
					if decision.success then -- 2435
						return ____awaiter_resolve(nil, decision) -- 2435
					end -- 2435
					lastError = decision.message -- 2440
					lastRaw = decision.raw or "" -- 2441
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2442
					attempt = attempt + 1 -- 2426
				end -- 2426
			end -- 2426
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2444
			return ____awaiter_resolve( -- 2444
				nil, -- 2444
				{ -- 2445
					success = false, -- 2445
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2445
				} -- 2445
			) -- 2445
		end -- 2445
		local lastError = "xml validation failed" -- 2448
		local lastRaw = "" -- 2449
		do -- 2449
			local attempt = 0 -- 2450
			while attempt < shared.llmMaxTry do -- 2450
				do -- 2450
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2451
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2459
					if shared.stopToken.stopped then -- 2459
						return ____awaiter_resolve( -- 2459
							nil, -- 2459
							{ -- 2461
								success = false, -- 2461
								message = getCancelledReason(shared) -- 2461
							} -- 2461
						) -- 2461
					end -- 2461
					if not llmRes.success then -- 2461
						lastError = llmRes.message -- 2464
						lastRaw = llmRes.text or "" -- 2465
						goto __continue393 -- 2466
					end -- 2466
					lastRaw = llmRes.text -- 2468
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2469
					if decision.success then -- 2469
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2469
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2472
							return ____awaiter_resolve( -- 2472
								nil, -- 2472
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2473
							) -- 2473
						end -- 2473
						return ____awaiter_resolve(nil, decision) -- 2473
					end -- 2473
					lastError = decision.message -- 2477
					return ____awaiter_resolve( -- 2477
						nil, -- 2477
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2478
					) -- 2478
				end -- 2478
				::__continue393:: -- 2478
				attempt = attempt + 1 -- 2450
			end -- 2450
		end -- 2450
		return ____awaiter_resolve( -- 2450
			nil, -- 2450
			{ -- 2480
				success = false, -- 2480
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2480
			} -- 2480
		) -- 2480
	end) -- 2480
end -- 2412
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2483
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2483
		local result = execRes -- 2484
		if not result.success then -- 2484
			if shared.stopToken.stopped then -- 2484
				shared.error = getCancelledReason(shared) -- 2487
				shared.done = true -- 2488
				return ____awaiter_resolve(nil, "done") -- 2488
			end -- 2488
			shared.error = result.message -- 2491
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2492
			shared.done = true -- 2493
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2494
			persistHistoryState(shared) -- 2498
			return ____awaiter_resolve(nil, "done") -- 2498
		end -- 2498
		if result.directSummary and result.directSummary ~= "" then -- 2498
			shared.response = result.directSummary -- 2502
			shared.done = true -- 2503
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2504
			persistHistoryState(shared) -- 2509
			return ____awaiter_resolve(nil, "done") -- 2509
		end -- 2509
		if result.tool == "finish" then -- 2509
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2513
			shared.response = finalMessage -- 2514
			shared.done = true -- 2515
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2516
			persistHistoryState(shared) -- 2521
			return ____awaiter_resolve(nil, "done") -- 2521
		end -- 2521
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2524
		shared.step = shared.step + 1 -- 2525
		local step = shared.step -- 2526
		emitAgentEvent(shared, { -- 2527
			type = "decision_made", -- 2528
			sessionId = shared.sessionId, -- 2529
			taskId = shared.taskId, -- 2530
			step = step, -- 2531
			tool = result.tool, -- 2532
			reason = result.reason, -- 2533
			reasoningContent = result.reasoningContent, -- 2534
			params = result.params -- 2535
		}) -- 2535
		local ____shared_history_45 = shared.history -- 2535
		____shared_history_45[#____shared_history_45 + 1] = { -- 2537
			step = step, -- 2538
			toolCallId = toolCallId, -- 2539
			tool = result.tool, -- 2540
			reason = result.reason or "", -- 2541
			reasoningContent = result.reasoningContent, -- 2542
			params = result.params, -- 2543
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2544
		} -- 2544
		appendConversationMessage( -- 2546
			shared, -- 2546
			{ -- 2546
				role = "assistant", -- 2547
				content = result.reason or "", -- 2548
				reasoning_content = result.reasoningContent, -- 2549
				tool_calls = {{ -- 2550
					id = toolCallId, -- 2551
					type = "function", -- 2552
					["function"] = { -- 2553
						name = result.tool, -- 2554
						arguments = toJson(result.params) -- 2555
					} -- 2555
				}} -- 2555
			} -- 2555
		) -- 2555
		persistHistoryState(shared) -- 2559
		return ____awaiter_resolve(nil, result.tool) -- 2559
	end) -- 2559
end -- 2483
local ReadFileAction = __TS__Class() -- 2564
ReadFileAction.name = "ReadFileAction" -- 2564
__TS__ClassExtends(ReadFileAction, Node) -- 2564
function ReadFileAction.prototype.prep(self, shared) -- 2565
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2565
		local last = shared.history[#shared.history] -- 2566
		if not last then -- 2566
			error( -- 2567
				__TS__New(Error, "no history"), -- 2567
				0 -- 2567
			) -- 2567
		end -- 2567
		emitAgentStartEvent(shared, last) -- 2568
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2569
		if __TS__StringTrim(path) == "" then -- 2569
			error( -- 2572
				__TS__New(Error, "missing path"), -- 2572
				0 -- 2572
			) -- 2572
		end -- 2572
		local ____path_48 = path -- 2574
		local ____shared_workingDir_49 = shared.workingDir -- 2576
		local ____temp_50 = shared.useChineseResponse and "zh" or "en" -- 2577
		local ____last_params_startLine_46 = last.params.startLine -- 2578
		if ____last_params_startLine_46 == nil then -- 2578
			____last_params_startLine_46 = 1 -- 2578
		end -- 2578
		local ____TS__Number_result_51 = __TS__Number(____last_params_startLine_46) -- 2578
		local ____last_params_endLine_47 = last.params.endLine -- 2579
		if ____last_params_endLine_47 == nil then -- 2579
			____last_params_endLine_47 = READ_FILE_DEFAULT_LIMIT -- 2579
		end -- 2579
		return ____awaiter_resolve( -- 2579
			nil, -- 2579
			{ -- 2573
				path = ____path_48, -- 2574
				tool = "read_file", -- 2575
				workDir = ____shared_workingDir_49, -- 2576
				docLanguage = ____temp_50, -- 2577
				startLine = ____TS__Number_result_51, -- 2578
				endLine = __TS__Number(____last_params_endLine_47) -- 2579
			} -- 2579
		) -- 2579
	end) -- 2579
end -- 2565
function ReadFileAction.prototype.exec(self, input) -- 2583
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2583
		return ____awaiter_resolve( -- 2583
			nil, -- 2583
			Tools.readFile( -- 2584
				input.workDir, -- 2585
				input.path, -- 2586
				__TS__Number(input.startLine or 1), -- 2587
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2588
				input.docLanguage -- 2589
			) -- 2589
		) -- 2589
	end) -- 2589
end -- 2583
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2593
		local result = execRes -- 2594
		local last = shared.history[#shared.history] -- 2595
		if last ~= nil then -- 2595
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2597
			appendToolResultMessage(shared, last) -- 2598
			emitAgentFinishEvent(shared, last) -- 2599
		end -- 2599
		persistHistoryState(shared) -- 2601
		__TS__Await(maybeCompressHistory(shared)) -- 2602
		persistHistoryState(shared) -- 2603
		return ____awaiter_resolve(nil, "main") -- 2603
	end) -- 2603
end -- 2593
local SearchFilesAction = __TS__Class() -- 2608
SearchFilesAction.name = "SearchFilesAction" -- 2608
__TS__ClassExtends(SearchFilesAction, Node) -- 2608
function SearchFilesAction.prototype.prep(self, shared) -- 2609
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2609
		local last = shared.history[#shared.history] -- 2610
		if not last then -- 2610
			error( -- 2611
				__TS__New(Error, "no history"), -- 2611
				0 -- 2611
			) -- 2611
		end -- 2611
		emitAgentStartEvent(shared, last) -- 2612
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2612
	end) -- 2612
end -- 2609
function SearchFilesAction.prototype.exec(self, input) -- 2616
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2616
		local params = input.params -- 2617
		local ____Tools_searchFiles_65 = Tools.searchFiles -- 2618
		local ____input_workDir_58 = input.workDir -- 2619
		local ____temp_59 = params.path or "" -- 2620
		local ____temp_60 = params.pattern or "" -- 2621
		local ____params_globs_61 = params.globs -- 2622
		local ____params_useRegex_62 = params.useRegex -- 2623
		local ____params_caseSensitive_63 = params.caseSensitive -- 2624
		local ____math_max_54 = math.max -- 2627
		local ____math_floor_53 = math.floor -- 2627
		local ____params_limit_52 = params.limit -- 2627
		if ____params_limit_52 == nil then -- 2627
			____params_limit_52 = SEARCH_FILES_LIMIT_DEFAULT -- 2627
		end -- 2627
		local ____math_max_54_result_64 = ____math_max_54( -- 2627
			1, -- 2627
			____math_floor_53(__TS__Number(____params_limit_52)) -- 2627
		) -- 2627
		local ____math_max_57 = math.max -- 2628
		local ____math_floor_56 = math.floor -- 2628
		local ____params_offset_55 = params.offset -- 2628
		if ____params_offset_55 == nil then -- 2628
			____params_offset_55 = 0 -- 2628
		end -- 2628
		local result = __TS__Await(____Tools_searchFiles_65({ -- 2618
			workDir = ____input_workDir_58, -- 2619
			path = ____temp_59, -- 2620
			pattern = ____temp_60, -- 2621
			globs = ____params_globs_61, -- 2622
			useRegex = ____params_useRegex_62, -- 2623
			caseSensitive = ____params_caseSensitive_63, -- 2624
			includeContent = true, -- 2625
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2626
			limit = ____math_max_54_result_64, -- 2627
			offset = ____math_max_57( -- 2628
				0, -- 2628
				____math_floor_56(__TS__Number(____params_offset_55)) -- 2628
			), -- 2628
			groupByFile = params.groupByFile == true -- 2629
		})) -- 2629
		return ____awaiter_resolve(nil, result) -- 2629
	end) -- 2629
end -- 2616
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2634
		local last = shared.history[#shared.history] -- 2635
		if last ~= nil then -- 2635
			local result = execRes -- 2637
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2638
			appendToolResultMessage(shared, last) -- 2639
			emitAgentFinishEvent(shared, last) -- 2640
		end -- 2640
		persistHistoryState(shared) -- 2642
		__TS__Await(maybeCompressHistory(shared)) -- 2643
		persistHistoryState(shared) -- 2644
		return ____awaiter_resolve(nil, "main") -- 2644
	end) -- 2644
end -- 2634
local SearchDoraAPIAction = __TS__Class() -- 2649
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2649
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2649
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2650
		local last = shared.history[#shared.history] -- 2651
		if not last then -- 2651
			error( -- 2652
				__TS__New(Error, "no history"), -- 2652
				0 -- 2652
			) -- 2652
		end -- 2652
		emitAgentStartEvent(shared, last) -- 2653
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2653
	end) -- 2653
end -- 2650
function SearchDoraAPIAction.prototype.exec(self, input) -- 2657
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2657
		local params = input.params -- 2658
		local ____Tools_searchDoraAPI_73 = Tools.searchDoraAPI -- 2659
		local ____temp_69 = params.pattern or "" -- 2660
		local ____temp_70 = params.docSource or "api" -- 2661
		local ____temp_71 = input.useChineseResponse and "zh" or "en" -- 2662
		local ____temp_72 = params.programmingLanguage or "ts" -- 2663
		local ____math_min_68 = math.min -- 2664
		local ____math_max_67 = math.max -- 2664
		local ____params_limit_66 = params.limit -- 2664
		if ____params_limit_66 == nil then -- 2664
			____params_limit_66 = 8 -- 2664
		end -- 2664
		local result = __TS__Await(____Tools_searchDoraAPI_73({ -- 2659
			pattern = ____temp_69, -- 2660
			docSource = ____temp_70, -- 2661
			docLanguage = ____temp_71, -- 2662
			programmingLanguage = ____temp_72, -- 2663
			limit = ____math_min_68( -- 2664
				SEARCH_DORA_API_LIMIT_MAX, -- 2664
				____math_max_67( -- 2664
					1, -- 2664
					__TS__Number(____params_limit_66) -- 2664
				) -- 2664
			), -- 2664
			useRegex = params.useRegex, -- 2665
			caseSensitive = false, -- 2666
			includeContent = true, -- 2667
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2668
		})) -- 2668
		return ____awaiter_resolve(nil, result) -- 2668
	end) -- 2668
end -- 2657
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2673
		local last = shared.history[#shared.history] -- 2674
		if last ~= nil then -- 2674
			local result = execRes -- 2676
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2677
			appendToolResultMessage(shared, last) -- 2678
			emitAgentFinishEvent(shared, last) -- 2679
		end -- 2679
		persistHistoryState(shared) -- 2681
		__TS__Await(maybeCompressHistory(shared)) -- 2682
		persistHistoryState(shared) -- 2683
		return ____awaiter_resolve(nil, "main") -- 2683
	end) -- 2683
end -- 2673
local ListFilesAction = __TS__Class() -- 2688
ListFilesAction.name = "ListFilesAction" -- 2688
__TS__ClassExtends(ListFilesAction, Node) -- 2688
function ListFilesAction.prototype.prep(self, shared) -- 2689
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2689
		local last = shared.history[#shared.history] -- 2690
		if not last then -- 2690
			error( -- 2691
				__TS__New(Error, "no history"), -- 2691
				0 -- 2691
			) -- 2691
		end -- 2691
		emitAgentStartEvent(shared, last) -- 2692
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2692
	end) -- 2692
end -- 2689
function ListFilesAction.prototype.exec(self, input) -- 2696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2696
		local params = input.params -- 2697
		local ____Tools_listFiles_80 = Tools.listFiles -- 2698
		local ____input_workDir_77 = input.workDir -- 2699
		local ____temp_78 = params.path or "" -- 2700
		local ____params_globs_79 = params.globs -- 2701
		local ____math_max_76 = math.max -- 2702
		local ____math_floor_75 = math.floor -- 2702
		local ____params_maxEntries_74 = params.maxEntries -- 2702
		if ____params_maxEntries_74 == nil then -- 2702
			____params_maxEntries_74 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2702
		end -- 2702
		local result = ____Tools_listFiles_80({ -- 2698
			workDir = ____input_workDir_77, -- 2699
			path = ____temp_78, -- 2700
			globs = ____params_globs_79, -- 2701
			maxEntries = ____math_max_76( -- 2702
				1, -- 2702
				____math_floor_75(__TS__Number(____params_maxEntries_74)) -- 2702
			) -- 2702
		}) -- 2702
		return ____awaiter_resolve(nil, result) -- 2702
	end) -- 2702
end -- 2696
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2707
		local last = shared.history[#shared.history] -- 2708
		if last ~= nil then -- 2708
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2710
			appendToolResultMessage(shared, last) -- 2711
			emitAgentFinishEvent(shared, last) -- 2712
		end -- 2712
		persistHistoryState(shared) -- 2714
		__TS__Await(maybeCompressHistory(shared)) -- 2715
		persistHistoryState(shared) -- 2716
		return ____awaiter_resolve(nil, "main") -- 2716
	end) -- 2716
end -- 2707
local DeleteFileAction = __TS__Class() -- 2721
DeleteFileAction.name = "DeleteFileAction" -- 2721
__TS__ClassExtends(DeleteFileAction, Node) -- 2721
function DeleteFileAction.prototype.prep(self, shared) -- 2722
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2722
		local last = shared.history[#shared.history] -- 2723
		if not last then -- 2723
			error( -- 2724
				__TS__New(Error, "no history"), -- 2724
				0 -- 2724
			) -- 2724
		end -- 2724
		emitAgentStartEvent(shared, last) -- 2725
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2726
		if __TS__StringTrim(targetFile) == "" then -- 2726
			error( -- 2729
				__TS__New(Error, "missing target_file"), -- 2729
				0 -- 2729
			) -- 2729
		end -- 2729
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2729
	end) -- 2729
end -- 2722
function DeleteFileAction.prototype.exec(self, input) -- 2733
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2733
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2734
		if not result.success then -- 2734
			return ____awaiter_resolve(nil, result) -- 2734
		end -- 2734
		return ____awaiter_resolve(nil, { -- 2734
			success = true, -- 2742
			changed = true, -- 2743
			mode = "delete", -- 2744
			checkpointId = result.checkpointId, -- 2745
			checkpointSeq = result.checkpointSeq, -- 2746
			files = {{path = input.targetFile, op = "delete"}} -- 2747
		}) -- 2747
	end) -- 2747
end -- 2733
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2751
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2751
		local last = shared.history[#shared.history] -- 2752
		if last ~= nil then -- 2752
			last.result = execRes -- 2754
			appendToolResultMessage(shared, last) -- 2755
			emitAgentFinishEvent(shared, last) -- 2756
			local result = last.result -- 2757
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2757
				emitAgentEvent(shared, { -- 2762
					type = "checkpoint_created", -- 2763
					sessionId = shared.sessionId, -- 2764
					taskId = shared.taskId, -- 2765
					step = last.step, -- 2766
					tool = "delete_file", -- 2767
					checkpointId = result.checkpointId, -- 2768
					checkpointSeq = result.checkpointSeq, -- 2769
					files = result.files -- 2770
				}) -- 2770
			end -- 2770
		end -- 2770
		persistHistoryState(shared) -- 2774
		__TS__Await(maybeCompressHistory(shared)) -- 2775
		persistHistoryState(shared) -- 2776
		return ____awaiter_resolve(nil, "main") -- 2776
	end) -- 2776
end -- 2751
local BuildAction = __TS__Class() -- 2781
BuildAction.name = "BuildAction" -- 2781
__TS__ClassExtends(BuildAction, Node) -- 2781
function BuildAction.prototype.prep(self, shared) -- 2782
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2782
		local last = shared.history[#shared.history] -- 2783
		if not last then -- 2783
			error( -- 2784
				__TS__New(Error, "no history"), -- 2784
				0 -- 2784
			) -- 2784
		end -- 2784
		emitAgentStartEvent(shared, last) -- 2785
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2785
	end) -- 2785
end -- 2782
function BuildAction.prototype.exec(self, input) -- 2789
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2789
		local params = input.params -- 2790
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2791
		return ____awaiter_resolve(nil, result) -- 2791
	end) -- 2791
end -- 2789
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2798
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2798
		local last = shared.history[#shared.history] -- 2799
		if last ~= nil then -- 2799
			last.result = execRes -- 2801
			appendToolResultMessage(shared, last) -- 2802
			emitAgentFinishEvent(shared, last) -- 2803
		end -- 2803
		persistHistoryState(shared) -- 2805
		__TS__Await(maybeCompressHistory(shared)) -- 2806
		persistHistoryState(shared) -- 2807
		return ____awaiter_resolve(nil, "main") -- 2807
	end) -- 2807
end -- 2798
local SpawnSubAgentAction = __TS__Class() -- 2812
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2812
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2812
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2813
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2813
		local last = shared.history[#shared.history] -- 2822
		if not last then -- 2822
			error( -- 2823
				__TS__New(Error, "no history"), -- 2823
				0 -- 2823
			) -- 2823
		end -- 2823
		emitAgentStartEvent(shared, last) -- 2824
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2825
			last.params.filesHint, -- 2826
			function(____, item) return type(item) == "string" end -- 2826
		) or nil -- 2826
		return ____awaiter_resolve( -- 2826
			nil, -- 2826
			{ -- 2828
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2829
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2830
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2831
				filesHint = filesHint, -- 2832
				sessionId = shared.sessionId, -- 2833
				projectRoot = shared.workingDir, -- 2834
				spawnSubAgent = shared.spawnSubAgent -- 2835
			} -- 2835
		) -- 2835
	end) -- 2835
end -- 2813
function SpawnSubAgentAction.prototype.exec(self, input) -- 2839
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2839
		if not input.spawnSubAgent then -- 2839
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2839
		end -- 2839
		if input.sessionId == nil or input.sessionId <= 0 then -- 2839
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2839
		end -- 2839
		local ____Log_86 = Log -- 2854
		local ____temp_83 = #input.title -- 2854
		local ____temp_84 = #input.prompt -- 2854
		local ____temp_85 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2854
		local ____opt_81 = input.filesHint -- 2854
		____Log_86( -- 2854
			"Info", -- 2854
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_83)) .. " prompt_len=") .. tostring(____temp_84)) .. " expected_len=") .. tostring(____temp_85)) .. " files_hint_count=") .. tostring(____opt_81 and #____opt_81 or 0) -- 2854
		) -- 2854
		local result = __TS__Await(input:spawnSubAgent({ -- 2855
			parentSessionId = input.sessionId, -- 2856
			projectRoot = input.projectRoot, -- 2857
			title = input.title, -- 2858
			prompt = input.prompt, -- 2859
			expectedOutput = input.expectedOutput, -- 2860
			filesHint = input.filesHint -- 2861
		})) -- 2861
		if not result.success then -- 2861
			return ____awaiter_resolve(nil, result) -- 2861
		end -- 2861
		return ____awaiter_resolve(nil, { -- 2861
			success = true, -- 2867
			sessionId = result.sessionId, -- 2868
			taskId = result.taskId, -- 2869
			title = result.title, -- 2870
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 2871
		}) -- 2871
	end) -- 2871
end -- 2839
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 2875
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2875
		local last = shared.history[#shared.history] -- 2876
		if last ~= nil then -- 2876
			last.result = execRes -- 2878
			appendToolResultMessage(shared, last) -- 2879
			emitAgentFinishEvent(shared, last) -- 2880
		end -- 2880
		persistHistoryState(shared) -- 2882
		__TS__Await(maybeCompressHistory(shared)) -- 2883
		persistHistoryState(shared) -- 2884
		return ____awaiter_resolve(nil, "main") -- 2884
	end) -- 2884
end -- 2875
local ListSubAgentsAction = __TS__Class() -- 2889
ListSubAgentsAction.name = "ListSubAgentsAction" -- 2889
__TS__ClassExtends(ListSubAgentsAction, Node) -- 2889
function ListSubAgentsAction.prototype.prep(self, shared) -- 2890
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2890
		local last = shared.history[#shared.history] -- 2899
		if not last then -- 2899
			error( -- 2900
				__TS__New(Error, "no history"), -- 2900
				0 -- 2900
			) -- 2900
		end -- 2900
		emitAgentStartEvent(shared, last) -- 2901
		return ____awaiter_resolve( -- 2901
			nil, -- 2901
			{ -- 2902
				sessionId = shared.sessionId, -- 2903
				projectRoot = shared.workingDir, -- 2904
				status = type(last.params.status) == "string" and last.params.status or nil, -- 2905
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 2906
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 2907
				query = type(last.params.query) == "string" and last.params.query or nil, -- 2908
				listSubAgents = shared.listSubAgents -- 2909
			} -- 2909
		) -- 2909
	end) -- 2909
end -- 2890
function ListSubAgentsAction.prototype.exec(self, input) -- 2913
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2913
		if not input.listSubAgents then -- 2913
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 2913
		end -- 2913
		if input.sessionId == nil or input.sessionId <= 0 then -- 2913
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 2913
		end -- 2913
		local result = __TS__Await(input:listSubAgents({ -- 2928
			sessionId = input.sessionId, -- 2929
			projectRoot = input.projectRoot, -- 2930
			status = input.status, -- 2931
			limit = input.limit, -- 2932
			offset = input.offset, -- 2933
			query = input.query -- 2934
		})) -- 2934
		return ____awaiter_resolve(nil, result) -- 2934
	end) -- 2934
end -- 2913
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 2939
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2939
		local last = shared.history[#shared.history] -- 2940
		if last ~= nil then -- 2940
			last.result = execRes -- 2942
			appendToolResultMessage(shared, last) -- 2943
			emitAgentFinishEvent(shared, last) -- 2944
		end -- 2944
		persistHistoryState(shared) -- 2946
		__TS__Await(maybeCompressHistory(shared)) -- 2947
		persistHistoryState(shared) -- 2948
		return ____awaiter_resolve(nil, "main") -- 2948
	end) -- 2948
end -- 2939
local EditFileAction = __TS__Class() -- 2953
EditFileAction.name = "EditFileAction" -- 2953
__TS__ClassExtends(EditFileAction, Node) -- 2953
function EditFileAction.prototype.prep(self, shared) -- 2954
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2954
		local last = shared.history[#shared.history] -- 2955
		if not last then -- 2955
			error( -- 2956
				__TS__New(Error, "no history"), -- 2956
				0 -- 2956
			) -- 2956
		end -- 2956
		emitAgentStartEvent(shared, last) -- 2957
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2958
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2961
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2962
		if __TS__StringTrim(path) == "" then -- 2962
			error( -- 2963
				__TS__New(Error, "missing path"), -- 2963
				0 -- 2963
			) -- 2963
		end -- 2963
		return ____awaiter_resolve(nil, { -- 2963
			path = path, -- 2964
			oldStr = oldStr, -- 2964
			newStr = newStr, -- 2964
			taskId = shared.taskId, -- 2964
			workDir = shared.workingDir -- 2964
		}) -- 2964
	end) -- 2964
end -- 2954
function EditFileAction.prototype.exec(self, input) -- 2967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2967
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2968
		if not readRes.success then -- 2968
			if input.oldStr ~= "" then -- 2968
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2968
			end -- 2968
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2973
			if not createRes.success then -- 2973
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2973
			end -- 2973
			return ____awaiter_resolve(nil, { -- 2973
				success = true, -- 2981
				changed = true, -- 2982
				mode = "create", -- 2983
				checkpointId = createRes.checkpointId, -- 2984
				checkpointSeq = createRes.checkpointSeq, -- 2985
				files = {{path = input.path, op = "create"}} -- 2986
			}) -- 2986
		end -- 2986
		if input.oldStr == "" then -- 2986
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2990
			if not overwriteRes.success then -- 2990
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2990
			end -- 2990
			return ____awaiter_resolve(nil, { -- 2990
				success = true, -- 2998
				changed = true, -- 2999
				mode = "overwrite", -- 3000
				checkpointId = overwriteRes.checkpointId, -- 3001
				checkpointSeq = overwriteRes.checkpointSeq, -- 3002
				files = {{path = input.path, op = "write"}} -- 3003
			}) -- 3003
		end -- 3003
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3008
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3009
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3010
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3013
		if occurrences == 0 then -- 3013
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3015
			if not indentTolerant.success then -- 3015
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3015
			end -- 3015
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3019
			if not applyRes.success then -- 3019
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3019
			end -- 3019
			return ____awaiter_resolve(nil, { -- 3019
				success = true, -- 3027
				changed = true, -- 3028
				mode = "replace_indent_tolerant", -- 3029
				checkpointId = applyRes.checkpointId, -- 3030
				checkpointSeq = applyRes.checkpointSeq, -- 3031
				files = {{path = input.path, op = "write"}} -- 3032
			}) -- 3032
		end -- 3032
		if occurrences > 1 then -- 3032
			return ____awaiter_resolve( -- 3032
				nil, -- 3032
				{ -- 3036
					success = false, -- 3036
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3036
				} -- 3036
			) -- 3036
		end -- 3036
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3040
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3041
		if not applyRes.success then -- 3041
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3041
		end -- 3041
		return ____awaiter_resolve(nil, { -- 3041
			success = true, -- 3049
			changed = true, -- 3050
			mode = "replace", -- 3051
			checkpointId = applyRes.checkpointId, -- 3052
			checkpointSeq = applyRes.checkpointSeq, -- 3053
			files = {{path = input.path, op = "write"}} -- 3054
		}) -- 3054
	end) -- 3054
end -- 2967
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3058
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3058
		local last = shared.history[#shared.history] -- 3059
		if last ~= nil then -- 3059
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3061
			last.result = execRes -- 3062
			appendToolResultMessage(shared, last) -- 3063
			emitAgentFinishEvent(shared, last) -- 3064
			local result = last.result -- 3065
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3065
				emitAgentEvent(shared, { -- 3070
					type = "checkpoint_created", -- 3071
					sessionId = shared.sessionId, -- 3072
					taskId = shared.taskId, -- 3073
					step = last.step, -- 3074
					tool = last.tool, -- 3075
					checkpointId = result.checkpointId, -- 3076
					checkpointSeq = result.checkpointSeq, -- 3077
					files = result.files -- 3078
				}) -- 3078
			end -- 3078
		end -- 3078
		persistHistoryState(shared) -- 3082
		__TS__Await(maybeCompressHistory(shared)) -- 3083
		persistHistoryState(shared) -- 3084
		return ____awaiter_resolve(nil, "main") -- 3084
	end) -- 3084
end -- 3058
local EndNode = __TS__Class() -- 3089
EndNode.name = "EndNode" -- 3089
__TS__ClassExtends(EndNode, Node) -- 3089
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3090
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3090
		return ____awaiter_resolve(nil, nil) -- 3090
	end) -- 3090
end -- 3090
local CodingAgentFlow = __TS__Class() -- 3095
CodingAgentFlow.name = "CodingAgentFlow" -- 3095
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3095
function CodingAgentFlow.prototype.____constructor(self, role) -- 3096
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3097
	local read = __TS__New(ReadFileAction, 1, 0) -- 3098
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3099
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3100
	local list = __TS__New(ListFilesAction, 1, 0) -- 3101
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3102
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3103
	local build = __TS__New(BuildAction, 1, 0) -- 3104
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3105
	local edit = __TS__New(EditFileAction, 1, 0) -- 3106
	local done = __TS__New(EndNode, 1, 0) -- 3107
	main:on("grep_files", search) -- 3109
	main:on("search_dora_api", searchDora) -- 3110
	main:on("glob_files", list) -- 3111
	if role == "main" then -- 3111
		main:on("read_file", read) -- 3113
		main:on("list_sub_agents", listSub) -- 3114
		main:on("spawn_sub_agent", spawn) -- 3115
	else -- 3115
		main:on("read_file", read) -- 3117
		main:on("delete_file", del) -- 3118
		main:on("build", build) -- 3119
		main:on("edit_file", edit) -- 3120
	end -- 3120
	main:on("done", done) -- 3122
	search:on("main", main) -- 3124
	searchDora:on("main", main) -- 3125
	list:on("main", main) -- 3126
	listSub:on("main", main) -- 3127
	spawn:on("main", main) -- 3128
	read:on("main", main) -- 3129
	del:on("main", main) -- 3130
	build:on("main", main) -- 3131
	edit:on("main", main) -- 3132
	Flow.prototype.____constructor(self, main) -- 3134
end -- 3096
local function runCodingAgentAsync(options) -- 3156
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3156
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3156
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3156
		end -- 3156
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3160
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3161
		if not llmConfigRes.success then -- 3161
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3161
		end -- 3161
		local llmConfig = llmConfigRes.config -- 3167
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3168
		if not taskRes.success then -- 3168
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3168
		end -- 3168
		local compressor = __TS__New(MemoryCompressor, { -- 3175
			compressionThreshold = 0.8, -- 3176
			compressionTargetThreshold = 0.5, -- 3177
			maxCompressionRounds = 3, -- 3178
			projectDir = options.workDir, -- 3179
			llmConfig = llmConfig, -- 3180
			promptPack = options.promptPack, -- 3181
			scope = options.memoryScope -- 3182
		}) -- 3182
		local persistedSession = compressor:getStorage():readSessionState() -- 3184
		local promptPack = compressor:getPromptPack() -- 3185
		local shared = { -- 3187
			sessionId = options.sessionId, -- 3188
			taskId = taskRes.taskId, -- 3189
			role = options.role or "main", -- 3190
			maxSteps = math.max( -- 3191
				1, -- 3191
				math.floor(options.maxSteps or 50) -- 3191
			), -- 3191
			llmMaxTry = math.max( -- 3192
				1, -- 3192
				math.floor(options.llmMaxTry or 5) -- 3192
			), -- 3192
			step = 0, -- 3193
			done = false, -- 3194
			stopToken = options.stopToken or ({stopped = false}), -- 3195
			response = "", -- 3196
			userQuery = normalizedPrompt, -- 3197
			workingDir = options.workDir, -- 3198
			useChineseResponse = options.useChineseResponse == true, -- 3199
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3200
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 3203
			llmConfig = llmConfig, -- 3208
			onEvent = options.onEvent, -- 3209
			promptPack = promptPack, -- 3210
			history = {}, -- 3211
			messages = persistedSession.messages, -- 3212
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3213
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3214
			memory = {compressor = compressor}, -- 3216
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3220
			spawnSubAgent = options.spawnSubAgent, -- 3225
			listSubAgents = options.listSubAgents -- 3226
		} -- 3226
		local ____try = __TS__AsyncAwaiter(function() -- 3226
			emitAgentEvent(shared, { -- 3230
				type = "task_started", -- 3231
				sessionId = shared.sessionId, -- 3232
				taskId = shared.taskId, -- 3233
				prompt = shared.userQuery, -- 3234
				workDir = shared.workingDir, -- 3235
				maxSteps = shared.maxSteps -- 3236
			}) -- 3236
			if shared.stopToken.stopped then -- 3236
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3239
				return ____awaiter_resolve( -- 3239
					nil, -- 3239
					emitAgentTaskFinishEvent( -- 3240
						shared, -- 3240
						false, -- 3240
						getCancelledReason(shared) -- 3240
					) -- 3240
				) -- 3240
			end -- 3240
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3242
			local promptCommand = getPromptCommand(shared.userQuery) -- 3243
			if promptCommand == "reset" then -- 3243
				return ____awaiter_resolve( -- 3243
					nil, -- 3243
					resetSessionHistory(shared) -- 3245
				) -- 3245
			end -- 3245
			if promptCommand == "compact" then -- 3245
				return ____awaiter_resolve( -- 3245
					nil, -- 3245
					__TS__Await(compactAllHistory(shared)) -- 3248
				) -- 3248
			end -- 3248
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3250
			persistHistoryState(shared) -- 3254
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3255
			__TS__Await(flow:run(shared)) -- 3256
			if shared.stopToken.stopped then -- 3256
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3258
				return ____awaiter_resolve( -- 3258
					nil, -- 3258
					emitAgentTaskFinishEvent( -- 3259
						shared, -- 3259
						false, -- 3259
						getCancelledReason(shared) -- 3259
					) -- 3259
				) -- 3259
			end -- 3259
			if shared.error then -- 3259
				return ____awaiter_resolve( -- 3259
					nil, -- 3259
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3262
				) -- 3262
			end -- 3262
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3265
			return ____awaiter_resolve( -- 3265
				nil, -- 3265
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3266
			) -- 3266
		end) -- 3266
		__TS__Await(____try.catch( -- 3229
			____try, -- 3229
			function(____, e) -- 3229
				return ____awaiter_resolve( -- 3229
					nil, -- 3229
					finalizeAgentFailure( -- 3269
						shared, -- 3269
						tostring(e) -- 3269
					) -- 3269
				) -- 3269
			end -- 3269
		)) -- 3269
	end) -- 3269
end -- 3156
function ____exports.runCodingAgent(options, callback) -- 3273
	local ____self_87 = runCodingAgentAsync(options) -- 3273
	____self_87["then"]( -- 3273
		____self_87, -- 3273
		function(____, result) return callback(result) end -- 3274
	) -- 3274
end -- 3273
return ____exports -- 3273