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
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
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
local stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, applyCompressedSessionState, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, SEARCH_DORA_API_LIMIT_MAX -- 1
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
function emitAgentEvent(shared, event) -- 699
	if shared.onEvent then -- 699
		do -- 699
			local function ____catch(____error) -- 699
				Log( -- 704
					"Error", -- 704
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 704
				) -- 704
			end -- 704
			local ____try, ____hasReturned = pcall(function() -- 704
				shared:onEvent(event) -- 702
			end) -- 702
			if not ____try then -- 702
				____catch(____hasReturned) -- 702
			end -- 702
		end -- 702
	end -- 702
end -- 702
function truncateText(text, maxLen) -- 948
	if #text <= maxLen then -- 948
		return text -- 949
	end -- 949
	local nextPos = utf8.offset(text, maxLen + 1) -- 950
	if nextPos == nil then -- 950
		return text -- 951
	end -- 951
	return string.sub(text, 1, nextPos - 1) .. "..." -- 952
end -- 952
function getReplyLanguageDirective(shared) -- 962
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 963
end -- 963
function replacePromptVars(template, vars) -- 968
	local output = template -- 969
	for key in pairs(vars) do -- 970
		output = table.concat( -- 971
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 971
			vars[key] or "" or "," -- 971
		) -- 971
	end -- 971
	return output -- 973
end -- 973
function getDecisionToolDefinitions(shared) -- 1097
	local base = replacePromptVars( -- 1098
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1099
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1100
	) -- 1100
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this whenever the task requires direct coding, file editing, file deletion, build verification, documentation writing, or any other concrete execution work by a delegated sub agent.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1102
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1122
		getAllowedToolsForRole(shared.role), -- 1123
		", " -- 1123
	) or "" -- 1123
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1125
	if (shared and shared.decisionMode) ~= "xml" then -- 1125
		return withRole -- 1127
	end -- 1127
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1129
end -- 1129
function persistHistoryState(shared) -- 1379
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 1380
end -- 1380
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 1383
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 1388
	if carryMessage then -- 1388
		__TS__ArrayUnshift( -- 1390
			remainingMessages, -- 1390
			__TS__ObjectAssign( -- 1390
				{}, -- 1390
				carryMessage, -- 1391
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1390
			) -- 1390
		) -- 1390
	end -- 1390
	shared.messages = remainingMessages -- 1395
end -- 1395
function getAllowedToolsForRole(role) -- 1685
	return role == "main" and ({ -- 1686
		"read_file", -- 1687
		"grep_files", -- 1687
		"search_dora_api", -- 1687
		"glob_files", -- 1687
		"list_sub_agents", -- 1687
		"spawn_sub_agent", -- 1687
		"finish" -- 1687
	}) or ({ -- 1687
		"read_file", -- 1688
		"edit_file", -- 1688
		"delete_file", -- 1688
		"grep_files", -- 1688
		"search_dora_api", -- 1688
		"glob_files", -- 1688
		"build", -- 1688
		"finish" -- 1688
	}) -- 1688
end -- 1688
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1794
	if includeToolDefinitions == nil then -- 1794
		includeToolDefinitions = false -- 1794
	end -- 1794
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase using search/discovery tools, and decide when to delegate implementation work by spawning sub agents.\n\nRules:\n- Do not perform direct code editing, deletion, or build actions yourself.\n- Use spawn_sub_agent when the task requires concrete implementation or verification work.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Code changes, file deletion, build/compile verification, and documentation writing should be delegated to a sub agent.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 1795
	local sections = { -- 1819
		shared.promptPack.agentIdentityPrompt, -- 1820
		rolePrompt, -- 1821
		getReplyLanguageDirective(shared) -- 1822
	} -- 1822
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1824
	if memoryContext ~= "" then -- 1824
		sections[#sections + 1] = memoryContext -- 1826
	end -- 1826
	if includeToolDefinitions then -- 1826
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1829
		if shared.decisionMode == "xml" then -- 1829
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1831
		end -- 1831
	end -- 1831
	local skillsSection = buildSkillsSection(shared) -- 1835
	if skillsSection ~= "" then -- 1835
		sections[#sections + 1] = skillsSection -- 1837
	end -- 1837
	return table.concat(sections, "\n\n") -- 1839
end -- 1839
function buildSkillsSection(shared) -- 1842
	local ____opt_32 = shared.skills -- 1842
	if not (____opt_32 and ____opt_32.loader) then -- 1842
		return "" -- 1844
	end -- 1844
	return shared.skills.loader:buildSkillsPromptSection() -- 1846
end -- 1846
function buildXmlDecisionInstruction(shared, feedback) -- 1958
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1959
end -- 1959
function emitAgentTaskFinishEvent(shared, success, message) -- 3061
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3062
	emitAgentEvent(shared, { -- 3068
		type = "task_finished", -- 3069
		sessionId = shared.sessionId, -- 3070
		taskId = shared.taskId, -- 3071
		success = result.success, -- 3072
		message = result.message, -- 3073
		steps = result.steps -- 3074
	}) -- 3074
	return result -- 3076
end -- 3076
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
local function emitAgentStartEvent(shared, action) -- 709
	emitAgentEvent(shared, { -- 710
		type = "tool_started", -- 711
		sessionId = shared.sessionId, -- 712
		taskId = shared.taskId, -- 713
		step = action.step, -- 714
		tool = action.tool -- 715
	}) -- 715
end -- 709
local function emitAgentFinishEvent(shared, action) -- 719
	emitAgentEvent(shared, { -- 720
		type = "tool_finished", -- 721
		sessionId = shared.sessionId, -- 722
		taskId = shared.taskId, -- 723
		step = action.step, -- 724
		tool = action.tool, -- 725
		result = action.result or ({}) -- 726
	}) -- 726
end -- 719
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 730
	emitAgentEvent(shared, { -- 731
		type = "assistant_message_updated", -- 732
		sessionId = shared.sessionId, -- 733
		taskId = shared.taskId, -- 734
		step = shared.step + 1, -- 735
		content = content, -- 736
		reasoningContent = reasoningContent -- 737
	}) -- 737
end -- 730
local function getMemoryCompressionStartReason(shared) -- 741
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 742
end -- 741
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 747
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 748
end -- 747
local function getMemoryCompressionFailureReason(shared, ____error) -- 753
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 754
end -- 753
local function summarizeHistoryEntryPreview(text, maxChars) -- 759
	if maxChars == nil then -- 759
		maxChars = 180 -- 759
	end -- 759
	local trimmed = __TS__StringTrim(text) -- 760
	if trimmed == "" then -- 760
		return "" -- 761
	end -- 761
	return truncateText(trimmed, maxChars) -- 762
end -- 759
local function getCancelledReason(shared) -- 765
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 765
		return shared.stopToken.reason -- 766
	end -- 766
	return shared.useChineseResponse and "已取消" or "cancelled" -- 767
end -- 765
local function getMaxStepsReachedReason(shared) -- 770
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 771
end -- 770
local function getFailureSummaryFallback(shared, ____error) -- 776
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 777
end -- 776
local function finalizeAgentFailure(shared, ____error) -- 782
	if shared.stopToken.stopped then -- 782
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 784
		return emitAgentTaskFinishEvent( -- 785
			shared, -- 785
			false, -- 785
			getCancelledReason(shared) -- 785
		) -- 785
	end -- 785
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 787
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 788
end -- 782
local function getPromptCommand(prompt) -- 791
	local trimmed = __TS__StringTrim(prompt) -- 792
	if trimmed == "/compact" then -- 792
		return "compact" -- 793
	end -- 793
	if trimmed == "/reset" then -- 793
		return "reset" -- 794
	end -- 794
	return nil -- 795
end -- 791
function ____exports.truncateAgentUserPrompt(prompt) -- 798
	if not prompt then -- 798
		return "" -- 799
	end -- 799
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 799
		return prompt -- 800
	end -- 800
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 801
	if offset == nil then -- 801
		return prompt -- 802
	end -- 802
	return string.sub(prompt, 1, offset - 1) -- 803
end -- 798
local function canWriteStepLLMDebug(shared, stepId) -- 806
	if stepId == nil then -- 806
		stepId = shared.step + 1 -- 806
	end -- 806
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 807
end -- 806
local function ensureDirRecursive(dir) -- 814
	if not dir then -- 814
		return false -- 815
	end -- 815
	if Content:exist(dir) then -- 815
		return Content:isdir(dir) -- 816
	end -- 816
	local parent = Path:getPath(dir) -- 817
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 817
		return false -- 819
	end -- 819
	return Content:mkdir(dir) -- 821
end -- 814
local function encodeDebugJSON(value) -- 824
	local text, err = safeJsonEncode(value) -- 825
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 826
end -- 824
local function getStepLLMDebugDir(shared) -- 829
	return Path( -- 830
		shared.workingDir, -- 831
		".agent", -- 832
		tostring(shared.sessionId), -- 833
		tostring(shared.taskId) -- 834
	) -- 834
end -- 829
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 838
	return Path( -- 839
		getStepLLMDebugDir(shared), -- 839
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 839
	) -- 839
end -- 838
local function getLatestStepLLMDebugSeq(shared, stepId) -- 842
	if not canWriteStepLLMDebug(shared, stepId) then -- 842
		return 0 -- 843
	end -- 843
	local dir = getStepLLMDebugDir(shared) -- 844
	if not Content:exist(dir) or not Content:isdir(dir) then -- 844
		return 0 -- 845
	end -- 845
	local latest = 0 -- 846
	for ____, file in ipairs(Content:getFiles(dir)) do -- 847
		do -- 847
			local name = Path:getFilename(file) -- 848
			local seqText = string.match( -- 849
				name, -- 849
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 849
			) -- 849
			if seqText ~= nil then -- 849
				latest = math.max( -- 851
					latest, -- 851
					tonumber(seqText) -- 851
				) -- 851
				goto __continue120 -- 852
			end -- 852
			local legacyMatch = string.match( -- 854
				name, -- 854
				("^" .. tostring(stepId)) .. "_in%.md$" -- 854
			) -- 854
			if legacyMatch ~= nil then -- 854
				latest = math.max(latest, 1) -- 856
			end -- 856
		end -- 856
		::__continue120:: -- 856
	end -- 856
	return latest -- 859
end -- 842
local function writeStepLLMDebugFile(path, content) -- 862
	if not Content:save(path, content) then -- 862
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 864
		return false -- 865
	end -- 865
	return true -- 867
end -- 862
local function createStepLLMDebugPair(shared, stepId, inContent) -- 870
	if not canWriteStepLLMDebug(shared, stepId) then -- 870
		return 0 -- 871
	end -- 871
	local dir = getStepLLMDebugDir(shared) -- 872
	if not ensureDirRecursive(dir) then -- 872
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 874
		return 0 -- 875
	end -- 875
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 877
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 878
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 879
	if not writeStepLLMDebugFile(inPath, inContent) then -- 879
		return 0 -- 881
	end -- 881
	writeStepLLMDebugFile(outPath, "") -- 883
	return seq -- 884
end -- 870
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 887
	if not canWriteStepLLMDebug(shared, stepId) then -- 887
		return -- 888
	end -- 888
	local dir = getStepLLMDebugDir(shared) -- 889
	if not ensureDirRecursive(dir) then -- 889
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 891
		return -- 892
	end -- 892
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 894
	if latestSeq <= 0 then -- 894
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 896
		writeStepLLMDebugFile(outPath, content) -- 897
		return -- 898
	end -- 898
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 900
	writeStepLLMDebugFile(outPath, content) -- 901
end -- 887
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 904
	if not canWriteStepLLMDebug(shared, stepId) then -- 904
		return -- 905
	end -- 905
	local sections = { -- 906
		"# LLM Input", -- 907
		"session_id: " .. tostring(shared.sessionId), -- 908
		"task_id: " .. tostring(shared.taskId), -- 909
		"step_id: " .. tostring(stepId), -- 910
		"phase: " .. phase, -- 911
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 912
		"## Options", -- 913
		"```json", -- 914
		encodeDebugJSON(options), -- 915
		"```" -- 916
	} -- 916
	do -- 916
		local i = 0 -- 918
		while i < #messages do -- 918
			local message = messages[i + 1] -- 919
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 920
			sections[#sections + 1] = encodeDebugJSON(message) -- 921
			i = i + 1 -- 918
		end -- 918
	end -- 918
	createStepLLMDebugPair( -- 923
		shared, -- 923
		stepId, -- 923
		table.concat(sections, "\n") -- 923
	) -- 923
end -- 904
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 926
	if not canWriteStepLLMDebug(shared, stepId) then -- 926
		return -- 927
	end -- 927
	local ____array_2 = __TS__SparseArrayNew( -- 927
		"# LLM Output", -- 929
		"session_id: " .. tostring(shared.sessionId), -- 930
		"task_id: " .. tostring(shared.taskId), -- 931
		"step_id: " .. tostring(stepId), -- 932
		"phase: " .. phase, -- 933
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 934
		table.unpack(meta and ({ -- 935
			"## Meta", -- 935
			"```json", -- 935
			encodeDebugJSON(meta), -- 935
			"```" -- 935
		}) or ({})) -- 935
	) -- 935
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 935
	local sections = {__TS__SparseArraySpread(____array_2)} -- 928
	updateLatestStepLLMDebugOutput( -- 939
		shared, -- 939
		stepId, -- 939
		table.concat(sections, "\n") -- 939
	) -- 939
end -- 926
local function toJson(value) -- 942
	local text, err = safeJsonEncode(value) -- 943
	if text ~= nil then -- 943
		return text -- 944
	end -- 944
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 945
end -- 942
local function utf8TakeHead(text, maxChars) -- 955
	if maxChars <= 0 or text == "" then -- 955
		return "" -- 956
	end -- 956
	local nextPos = utf8.offset(text, maxChars + 1) -- 957
	if nextPos == nil then -- 957
		return text -- 958
	end -- 958
	return string.sub(text, 1, nextPos - 1) -- 959
end -- 955
local function limitReadContentForHistory(content, tool) -- 976
	local lines = __TS__StringSplit(content, "\n") -- 977
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 978
	local limitedByLines = overLineLimit and table.concat( -- 979
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 980
		"\n" -- 980
	) or content -- 980
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 980
		return content -- 983
	end -- 983
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 985
	local reasons = {} -- 988
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 988
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 989
	end -- 989
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 989
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 990
	end -- 990
	local hint = "Narrow the requested line range." -- 991
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 992
end -- 976
local function summarizeEditTextParamForHistory(value, key) -- 995
	if type(value) ~= "string" then -- 995
		return nil -- 996
	end -- 996
	local text = value -- 997
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 998
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 999
end -- 995
local function sanitizeReadResultForHistory(tool, result) -- 1007
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1007
		return result -- 1009
	end -- 1009
	local clone = {} -- 1011
	for key in pairs(result) do -- 1012
		clone[key] = result[key] -- 1013
	end -- 1013
	clone.content = limitReadContentForHistory(result.content, tool) -- 1015
	return clone -- 1016
end -- 1007
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1019
	local shown = math.min(#items, maxItems) -- 1023
	local out = {} -- 1024
	do -- 1024
		local i = 0 -- 1025
		while i < shown do -- 1025
			local row = items[i + 1] -- 1026
			out[#out + 1] = { -- 1027
				file = row.file, -- 1028
				line = row.line, -- 1029
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1030
			} -- 1030
			i = i + 1 -- 1025
		end -- 1025
	end -- 1025
	return out -- 1035
end -- 1019
local function sanitizeSearchResultForHistory(tool, result) -- 1038
	if result.success ~= true or not isArray(result.results) then -- 1038
		return result -- 1042
	end -- 1042
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1042
		return result -- 1043
	end -- 1043
	local clone = {} -- 1044
	for key in pairs(result) do -- 1045
		clone[key] = result[key] -- 1046
	end -- 1046
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1048
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1049
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1049
		local grouped = result.groupedResults -- 1054
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1055
		local sanitizedGroups = {} -- 1056
		do -- 1056
			local i = 0 -- 1057
			while i < shown do -- 1057
				local row = grouped[i + 1] -- 1058
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1059
					file = row.file, -- 1060
					totalMatches = row.totalMatches, -- 1061
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1062
				} -- 1062
				i = i + 1 -- 1057
			end -- 1057
		end -- 1057
		clone.groupedResults = sanitizedGroups -- 1067
	end -- 1067
	return clone -- 1069
end -- 1038
local function sanitizeListFilesResultForHistory(result) -- 1072
	if result.success ~= true or not isArray(result.files) then -- 1072
		return result -- 1073
	end -- 1073
	local clone = {} -- 1074
	for key in pairs(result) do -- 1075
		clone[key] = result[key] -- 1076
	end -- 1076
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1078
	return clone -- 1079
end -- 1072
local function sanitizeActionParamsForHistory(tool, params) -- 1082
	if tool ~= "edit_file" then -- 1082
		return params -- 1083
	end -- 1083
	local clone = {} -- 1084
	for key in pairs(params) do -- 1085
		if key == "old_str" then -- 1085
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1087
		elseif key == "new_str" then -- 1087
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1089
		else -- 1089
			clone[key] = params[key] -- 1091
		end -- 1091
	end -- 1091
	return clone -- 1094
end -- 1082
local function isToolAllowedForRole(role, tool) -- 1138
	return __TS__ArrayIndexOf( -- 1139
		getAllowedToolsForRole(role), -- 1139
		tool -- 1139
	) >= 0 -- 1139
end -- 1138
local function maybeCompressHistory(shared) -- 1142
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1142
		local ____shared_9 = shared -- 1143
		local memory = ____shared_9.memory -- 1143
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1144
		local changed = false -- 1145
		do -- 1145
			local round = 0 -- 1146
			while round < maxRounds do -- 1146
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1147
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1151
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 1151
					if changed then -- 1151
						persistHistoryState(shared) -- 1160
					end -- 1160
					return ____awaiter_resolve(nil) -- 1160
				end -- 1160
				local compressionRound = round + 1 -- 1164
				shared.step = shared.step + 1 -- 1165
				local stepId = shared.step -- 1166
				local pendingMessages = #shared.messages -- 1167
				emitAgentEvent( -- 1168
					shared, -- 1168
					{ -- 1168
						type = "memory_compression_started", -- 1169
						sessionId = shared.sessionId, -- 1170
						taskId = shared.taskId, -- 1171
						step = stepId, -- 1172
						tool = "compress_memory", -- 1173
						reason = getMemoryCompressionStartReason(shared), -- 1174
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1175
					} -- 1175
				) -- 1175
				local result = __TS__Await(memory.compressor:compress( -- 1181
					shared.messages, -- 1182
					shared.llmOptions, -- 1183
					shared.llmMaxTry, -- 1184
					shared.decisionMode, -- 1185
					{ -- 1186
						onInput = function(____, phase, messages, options) -- 1187
							saveStepLLMDebugInput( -- 1188
								shared, -- 1188
								stepId, -- 1188
								phase, -- 1188
								messages, -- 1188
								options -- 1188
							) -- 1188
						end, -- 1187
						onOutput = function(____, phase, text, meta) -- 1190
							saveStepLLMDebugOutput( -- 1191
								shared, -- 1191
								stepId, -- 1191
								phase, -- 1191
								text, -- 1191
								meta -- 1191
							) -- 1191
						end -- 1190
					}, -- 1190
					"default", -- 1194
					systemPrompt, -- 1195
					toolDefinitions -- 1196
				)) -- 1196
				if not (result and result.success and result.compressedCount > 0) then -- 1196
					emitAgentEvent( -- 1199
						shared, -- 1199
						{ -- 1199
							type = "memory_compression_finished", -- 1200
							sessionId = shared.sessionId, -- 1201
							taskId = shared.taskId, -- 1202
							step = stepId, -- 1203
							tool = "compress_memory", -- 1204
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1205
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1209
						} -- 1209
					) -- 1209
					if changed then -- 1209
						persistHistoryState(shared) -- 1217
					end -- 1217
					return ____awaiter_resolve(nil) -- 1217
				end -- 1217
				emitAgentEvent( -- 1221
					shared, -- 1221
					{ -- 1221
						type = "memory_compression_finished", -- 1222
						sessionId = shared.sessionId, -- 1223
						taskId = shared.taskId, -- 1224
						step = stepId, -- 1225
						tool = "compress_memory", -- 1226
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1227
						result = { -- 1228
							success = true, -- 1229
							round = compressionRound, -- 1230
							compressedCount = result.compressedCount, -- 1231
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1232
						} -- 1232
					} -- 1232
				) -- 1232
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1235
				changed = true -- 1236
				Log( -- 1237
					"Info", -- 1237
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1237
				) -- 1237
				round = round + 1 -- 1146
			end -- 1146
		end -- 1146
		if changed then -- 1146
			persistHistoryState(shared) -- 1240
		end -- 1240
	end) -- 1240
end -- 1142
local function compactAllHistory(shared) -- 1244
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1244
		local ____shared_16 = shared -- 1245
		local memory = ____shared_16.memory -- 1245
		local rounds = 0 -- 1246
		local totalCompressed = 0 -- 1247
		while #shared.messages > 0 do -- 1247
			if shared.stopToken.stopped then -- 1247
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1250
				return ____awaiter_resolve( -- 1250
					nil, -- 1250
					emitAgentTaskFinishEvent( -- 1251
						shared, -- 1251
						false, -- 1251
						getCancelledReason(shared) -- 1251
					) -- 1251
				) -- 1251
			end -- 1251
			rounds = rounds + 1 -- 1253
			shared.step = shared.step + 1 -- 1254
			local stepId = shared.step -- 1255
			local pendingMessages = #shared.messages -- 1256
			emitAgentEvent( -- 1257
				shared, -- 1257
				{ -- 1257
					type = "memory_compression_started", -- 1258
					sessionId = shared.sessionId, -- 1259
					taskId = shared.taskId, -- 1260
					step = stepId, -- 1261
					tool = "compress_memory", -- 1262
					reason = getMemoryCompressionStartReason(shared), -- 1263
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1264
				} -- 1264
			) -- 1264
			local result = __TS__Await(memory.compressor:compress( -- 1271
				shared.messages, -- 1272
				shared.llmOptions, -- 1273
				shared.llmMaxTry, -- 1274
				shared.decisionMode, -- 1275
				{ -- 1276
					onInput = function(____, phase, messages, options) -- 1277
						saveStepLLMDebugInput( -- 1278
							shared, -- 1278
							stepId, -- 1278
							phase, -- 1278
							messages, -- 1278
							options -- 1278
						) -- 1278
					end, -- 1277
					onOutput = function(____, phase, text, meta) -- 1280
						saveStepLLMDebugOutput( -- 1281
							shared, -- 1281
							stepId, -- 1281
							phase, -- 1281
							text, -- 1281
							meta -- 1281
						) -- 1281
					end -- 1280
				}, -- 1280
				"budget_max" -- 1284
			)) -- 1284
			if not (result and result.success and result.compressedCount > 0) then -- 1284
				emitAgentEvent( -- 1287
					shared, -- 1287
					{ -- 1287
						type = "memory_compression_finished", -- 1288
						sessionId = shared.sessionId, -- 1289
						taskId = shared.taskId, -- 1290
						step = stepId, -- 1291
						tool = "compress_memory", -- 1292
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1293
						result = { -- 1297
							success = false, -- 1298
							rounds = rounds, -- 1299
							error = result and result.error or "compression returned no changes", -- 1300
							compressedCount = result and result.compressedCount or 0, -- 1301
							fullCompaction = true -- 1302
						} -- 1302
					} -- 1302
				) -- 1302
				return ____awaiter_resolve( -- 1302
					nil, -- 1302
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1305
				) -- 1305
			end -- 1305
			emitAgentEvent( -- 1310
				shared, -- 1310
				{ -- 1310
					type = "memory_compression_finished", -- 1311
					sessionId = shared.sessionId, -- 1312
					taskId = shared.taskId, -- 1313
					step = stepId, -- 1314
					tool = "compress_memory", -- 1315
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1316
					result = { -- 1317
						success = true, -- 1318
						round = rounds, -- 1319
						compressedCount = result.compressedCount, -- 1320
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1321
						fullCompaction = true -- 1322
					} -- 1322
				} -- 1322
			) -- 1322
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1325
			totalCompressed = totalCompressed + result.compressedCount -- 1326
			persistHistoryState(shared) -- 1327
			Log( -- 1328
				"Info", -- 1328
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1328
			) -- 1328
		end -- 1328
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1330
		return ____awaiter_resolve( -- 1330
			nil, -- 1330
			emitAgentTaskFinishEvent( -- 1331
				shared, -- 1332
				true, -- 1333
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1334
			) -- 1334
		) -- 1334
	end) -- 1334
end -- 1244
local function resetSessionHistory(shared) -- 1340
	shared.messages = {} -- 1341
	persistHistoryState(shared) -- 1342
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1343
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1344
end -- 1340
local function isKnownToolName(name) -- 1353
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1354
end -- 1353
local function getFinishMessage(params, fallback) -- 1366
	if fallback == nil then -- 1366
		fallback = "" -- 1366
	end -- 1366
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1366
		return __TS__StringTrim(params.message) -- 1368
	end -- 1368
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1368
		return __TS__StringTrim(params.response) -- 1371
	end -- 1371
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1371
		return __TS__StringTrim(params.summary) -- 1374
	end -- 1374
	return __TS__StringTrim(fallback) -- 1376
end -- 1366
local function appendConversationMessage(shared, message) -- 1398
	local ____shared_messages_25 = shared.messages -- 1398
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1399
		{}, -- 1399
		message, -- 1400
		{ -- 1399
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1401
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1402
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1403
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1404
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1405
		} -- 1405
	) -- 1405
end -- 1398
local function ensureToolCallId(toolCallId) -- 1409
	if toolCallId and toolCallId ~= "" then -- 1409
		return toolCallId -- 1410
	end -- 1410
	return createLocalToolCallId() -- 1411
end -- 1409
local function appendToolResultMessage(shared, action) -- 1414
	appendConversationMessage( -- 1415
		shared, -- 1415
		{ -- 1415
			role = "tool", -- 1416
			tool_call_id = action.toolCallId, -- 1417
			name = action.tool, -- 1418
			content = action.result and toJson(action.result) or "" -- 1419
		} -- 1419
	) -- 1419
end -- 1414
local function parseXMLToolCallObjectFromText(text) -- 1423
	local children = parseXMLObjectFromText(text, "tool_call") -- 1424
	if not children.success then -- 1424
		return children -- 1425
	end -- 1425
	local rawObj = children.obj -- 1426
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1427
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1428
	if not params.success then -- 1428
		return {success = false, message = params.message} -- 1432
	end -- 1432
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1434
end -- 1423
local function llm(shared, messages, phase) -- 1453
	if phase == nil then -- 1453
		phase = "decision_xml" -- 1456
	end -- 1456
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1456
		local stepId = shared.step + 1 -- 1458
		saveStepLLMDebugInput( -- 1459
			shared, -- 1459
			stepId, -- 1459
			phase, -- 1459
			messages, -- 1459
			shared.llmOptions -- 1459
		) -- 1459
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1460
		if res.success then -- 1460
			local ____opt_30 = res.response.choices -- 1460
			local ____opt_28 = ____opt_30 and ____opt_30[1] -- 1460
			local ____opt_26 = ____opt_28 and ____opt_28.message -- 1460
			local text = ____opt_26 and ____opt_26.content -- 1462
			if text then -- 1462
				saveStepLLMDebugOutput( -- 1464
					shared, -- 1464
					stepId, -- 1464
					phase, -- 1464
					text, -- 1464
					{success = true} -- 1464
				) -- 1464
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 1464
			else -- 1464
				saveStepLLMDebugOutput( -- 1467
					shared, -- 1467
					stepId, -- 1467
					phase, -- 1467
					"empty LLM response", -- 1467
					{success = false} -- 1467
				) -- 1467
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1467
			end -- 1467
		else -- 1467
			saveStepLLMDebugOutput( -- 1471
				shared, -- 1471
				stepId, -- 1471
				phase, -- 1471
				res.raw or res.message, -- 1471
				{success = false} -- 1471
			) -- 1471
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1471
		end -- 1471
	end) -- 1471
end -- 1453
local function parseDecisionObject(rawObj) -- 1488
	if type(rawObj.tool) ~= "string" then -- 1488
		return {success = false, message = "missing tool"} -- 1489
	end -- 1489
	local tool = rawObj.tool -- 1490
	if not isKnownToolName(tool) then -- 1490
		return {success = false, message = "unknown tool: " .. tool} -- 1492
	end -- 1492
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1494
	if tool ~= "finish" and (not reason or reason == "") then -- 1494
		return {success = false, message = tool .. " requires top-level reason"} -- 1498
	end -- 1498
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1500
	return {success = true, tool = tool, params = params, reason = reason} -- 1501
end -- 1488
local function parseDecisionToolCall(functionName, rawObj) -- 1509
	if not isKnownToolName(functionName) then -- 1509
		return {success = false, message = "unknown tool: " .. functionName} -- 1511
	end -- 1511
	if rawObj == nil or rawObj == nil then -- 1511
		return {success = true, tool = functionName, params = {}} -- 1514
	end -- 1514
	if not isRecord(rawObj) then -- 1514
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1517
	end -- 1517
	return {success = true, tool = functionName, params = rawObj} -- 1519
end -- 1509
local function getDecisionPath(params) -- 1526
	if type(params.path) == "string" then -- 1526
		return __TS__StringTrim(params.path) -- 1527
	end -- 1527
	if type(params.target_file) == "string" then -- 1527
		return __TS__StringTrim(params.target_file) -- 1528
	end -- 1528
	return "" -- 1529
end -- 1526
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1532
	local num = __TS__Number(value) -- 1533
	if not __TS__NumberIsFinite(num) then -- 1533
		num = fallback -- 1534
	end -- 1534
	num = math.floor(num) -- 1535
	if num < minValue then -- 1535
		num = minValue -- 1536
	end -- 1536
	if maxValue ~= nil and num > maxValue then -- 1536
		num = maxValue -- 1537
	end -- 1537
	return num -- 1538
end -- 1532
local function parseReadLineParam(value, fallback, paramName) -- 1541
	local num = __TS__Number(value) -- 1546
	if not __TS__NumberIsFinite(num) then -- 1546
		num = fallback -- 1547
	end -- 1547
	num = math.floor(num) -- 1548
	if num == 0 then -- 1548
		return {success = false, message = paramName .. " cannot be 0"} -- 1550
	end -- 1550
	return {success = true, value = num} -- 1552
end -- 1541
local function validateDecision(tool, params) -- 1555
	if tool == "finish" then -- 1555
		local message = getFinishMessage(params) -- 1560
		if message == "" then -- 1560
			return {success = false, message = "finish requires params.message"} -- 1561
		end -- 1561
		params.message = message -- 1562
		return {success = true, params = params} -- 1563
	end -- 1563
	if tool == "read_file" then -- 1563
		local path = getDecisionPath(params) -- 1567
		if path == "" then -- 1567
			return {success = false, message = "read_file requires path"} -- 1568
		end -- 1568
		params.path = path -- 1569
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1570
		if not startLineRes.success then -- 1570
			return startLineRes -- 1571
		end -- 1571
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1572
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1573
		if not endLineRes.success then -- 1573
			return endLineRes -- 1574
		end -- 1574
		params.startLine = startLineRes.value -- 1575
		params.endLine = endLineRes.value -- 1576
		return {success = true, params = params} -- 1577
	end -- 1577
	if tool == "edit_file" then -- 1577
		local path = getDecisionPath(params) -- 1581
		if path == "" then -- 1581
			return {success = false, message = "edit_file requires path"} -- 1582
		end -- 1582
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1583
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1584
		params.path = path -- 1585
		params.old_str = oldStr -- 1586
		params.new_str = newStr -- 1587
		return {success = true, params = params} -- 1588
	end -- 1588
	if tool == "delete_file" then -- 1588
		local targetFile = getDecisionPath(params) -- 1592
		if targetFile == "" then -- 1592
			return {success = false, message = "delete_file requires target_file"} -- 1593
		end -- 1593
		params.target_file = targetFile -- 1594
		return {success = true, params = params} -- 1595
	end -- 1595
	if tool == "grep_files" then -- 1595
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1599
		if pattern == "" then -- 1599
			return {success = false, message = "grep_files requires pattern"} -- 1600
		end -- 1600
		params.pattern = pattern -- 1601
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1602
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1603
		return {success = true, params = params} -- 1604
	end -- 1604
	if tool == "search_dora_api" then -- 1604
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1608
		if pattern == "" then -- 1608
			return {success = false, message = "search_dora_api requires pattern"} -- 1609
		end -- 1609
		params.pattern = pattern -- 1610
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1611
		return {success = true, params = params} -- 1612
	end -- 1612
	if tool == "glob_files" then -- 1612
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1616
		return {success = true, params = params} -- 1617
	end -- 1617
	if tool == "build" then -- 1617
		local path = getDecisionPath(params) -- 1621
		if path ~= "" then -- 1621
			params.path = path -- 1623
		end -- 1623
		return {success = true, params = params} -- 1625
	end -- 1625
	if tool == "list_sub_agents" then -- 1625
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1629
		if status ~= "" then -- 1629
			params.status = status -- 1631
		end -- 1631
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1633
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1634
		if type(params.query) == "string" then -- 1634
			params.query = __TS__StringTrim(params.query) -- 1636
		end -- 1636
		return {success = true, params = params} -- 1638
	end -- 1638
	if tool == "spawn_sub_agent" then -- 1638
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1642
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1643
		if prompt == "" then -- 1643
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1644
		end -- 1644
		if title == "" then -- 1644
			return {success = false, message = "spawn_sub_agent requires title"} -- 1645
		end -- 1645
		params.prompt = prompt -- 1646
		params.title = title -- 1647
		if type(params.expectedOutput) == "string" then -- 1647
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1649
		end -- 1649
		if isArray(params.filesHint) then -- 1649
			params.filesHint = __TS__ArrayMap( -- 1652
				__TS__ArrayFilter( -- 1652
					params.filesHint, -- 1652
					function(____, item) return type(item) == "string" end -- 1653
				), -- 1653
				function(____, item) return sanitizeUTF8(item) end -- 1654
			) -- 1654
		end -- 1654
		return {success = true, params = params} -- 1656
	end -- 1656
	return {success = true, params = params} -- 1659
end -- 1555
local function createFunctionToolSchema(name, description, properties, required) -- 1662
	if required == nil then -- 1662
		required = {} -- 1666
	end -- 1666
	local parameters = {type = "object", properties = properties} -- 1668
	if #required > 0 then -- 1668
		parameters.required = required -- 1673
	end -- 1673
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1675
end -- 1662
local function buildDecisionToolSchema(shared) -- 1691
	local allowed = getAllowedToolsForRole(shared.role) -- 1692
	local tools = { -- 1693
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1694
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1704
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1714
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1722
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1726
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1727
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1728
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1729
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1730
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1731
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1732
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1733
		}, {"pattern"}), -- 1733
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1737
		createFunctionToolSchema( -- 1746
			"search_dora_api", -- 1747
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1747
			{ -- 1749
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1750
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1751
				programmingLanguage = {type = "string", enum = { -- 1752
					"ts", -- 1754
					"tsx", -- 1754
					"lua", -- 1754
					"yue", -- 1754
					"teal", -- 1754
					"tl", -- 1754
					"wa" -- 1754
				}, description = "Preferred language variant to search."}, -- 1754
				limit = { -- 1757
					type = "number", -- 1757
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1757
				}, -- 1757
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1758
			}, -- 1758
			{"pattern"} -- 1760
		), -- 1760
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1762
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 1769
			"active_or_recent", -- 1773
			"running", -- 1773
			"done", -- 1773
			"failed", -- 1773
			"all" -- 1773
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 1773
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute concrete work. Use this when the task moves from discussion/search into coding, file editing, file deletion, build verification, documentation writing, or other execution-heavy work. The sub agent has the full execution toolset including edit_file, delete_file, and build. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1779
	} -- 1779
	return __TS__ArrayFilter( -- 1791
		tools, -- 1791
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1791
	) -- 1791
end -- 1691
local function sanitizeMessagesForLLMInput(messages) -- 1849
	local sanitized = {} -- 1850
	local droppedAssistantToolCalls = 0 -- 1851
	local droppedToolResults = 0 -- 1852
	do -- 1852
		local i = 0 -- 1853
		while i < #messages do -- 1853
			do -- 1853
				local message = messages[i + 1] -- 1854
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1854
					local requiredIds = {} -- 1856
					do -- 1856
						local j = 0 -- 1857
						while j < #message.tool_calls do -- 1857
							local toolCall = message.tool_calls[j + 1] -- 1858
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1859
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1859
								requiredIds[#requiredIds + 1] = id -- 1861
							end -- 1861
							j = j + 1 -- 1857
						end -- 1857
					end -- 1857
					if #requiredIds == 0 then -- 1857
						sanitized[#sanitized + 1] = message -- 1865
						goto __continue284 -- 1866
					end -- 1866
					local matchedIds = {} -- 1868
					local matchedTools = {} -- 1869
					local j = i + 1 -- 1870
					while j < #messages do -- 1870
						local toolMessage = messages[j + 1] -- 1872
						if toolMessage.role ~= "tool" then -- 1872
							break -- 1873
						end -- 1873
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1874
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1874
							matchedIds[toolCallId] = true -- 1876
							matchedTools[#matchedTools + 1] = toolMessage -- 1877
						else -- 1877
							droppedToolResults = droppedToolResults + 1 -- 1879
						end -- 1879
						j = j + 1 -- 1881
					end -- 1881
					local complete = true -- 1883
					do -- 1883
						local j = 0 -- 1884
						while j < #requiredIds do -- 1884
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1884
								complete = false -- 1886
								break -- 1887
							end -- 1887
							j = j + 1 -- 1884
						end -- 1884
					end -- 1884
					if complete then -- 1884
						__TS__ArrayPush( -- 1891
							sanitized, -- 1891
							message, -- 1891
							table.unpack(matchedTools) -- 1891
						) -- 1891
					else -- 1891
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1893
						droppedToolResults = droppedToolResults + #matchedTools -- 1894
					end -- 1894
					i = j - 1 -- 1896
					goto __continue284 -- 1897
				end -- 1897
				if message.role == "tool" then -- 1897
					droppedToolResults = droppedToolResults + 1 -- 1900
					goto __continue284 -- 1901
				end -- 1901
				sanitized[#sanitized + 1] = message -- 1903
			end -- 1903
			::__continue284:: -- 1903
			i = i + 1 -- 1853
		end -- 1853
	end -- 1853
	return sanitized -- 1905
end -- 1849
local function getUnconsolidatedMessages(shared) -- 1908
	return sanitizeMessagesForLLMInput(shared.messages) -- 1909
end -- 1908
local function getFinalDecisionTurnPrompt(shared) -- 1912
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1913
end -- 1912
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1918
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1918
		return messages -- 1919
	end -- 1919
	local next = __TS__ArrayMap( -- 1920
		messages, -- 1920
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1920
	) -- 1920
	do -- 1920
		local i = #next - 1 -- 1921
		while i >= 0 do -- 1921
			do -- 1921
				local message = next[i + 1] -- 1922
				if message.role ~= "assistant" and message.role ~= "user" then -- 1922
					goto __continue306 -- 1923
				end -- 1923
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1924
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1925
				return next -- 1928
			end -- 1928
			::__continue306:: -- 1928
			i = i - 1 -- 1921
		end -- 1921
	end -- 1921
	next[#next + 1] = {role = "user", content = prompt} -- 1930
	return next -- 1931
end -- 1918
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1934
	if attempt == nil then -- 1934
		attempt = 1 -- 1934
	end -- 1934
	local messages = { -- 1935
		{ -- 1936
			role = "system", -- 1936
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1936
		}, -- 1936
		table.unpack(getUnconsolidatedMessages(shared)) -- 1937
	} -- 1937
	if shared.step + 1 >= shared.maxSteps then -- 1937
		messages = appendPromptToLatestDecisionMessage( -- 1940
			messages, -- 1940
			getFinalDecisionTurnPrompt(shared) -- 1940
		) -- 1940
	end -- 1940
	if lastError and lastError ~= "" then -- 1940
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1943
		messages[#messages + 1] = { -- 1946
			role = "user", -- 1947
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1948
		} -- 1948
	end -- 1948
	return messages -- 1955
end -- 1934
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1962
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1969
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1970
	local repairPrompt = replacePromptVars( -- 1978
		shared.promptPack.xmlDecisionRepairPrompt, -- 1978
		{ -- 1978
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1979
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1980
			CANDIDATE_SECTION = candidateSection, -- 1981
			LAST_ERROR = lastError, -- 1982
			ATTEMPT = tostring(attempt) -- 1983
		} -- 1983
	) -- 1983
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 1985
end -- 1962
local function tryParseAndValidateDecision(rawText) -- 1997
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1998
	if not parsed.success then -- 1998
		return {success = false, message = parsed.message, raw = rawText} -- 2000
	end -- 2000
	local decision = parseDecisionObject(parsed.obj) -- 2002
	if not decision.success then -- 2002
		return {success = false, message = decision.message, raw = rawText} -- 2004
	end -- 2004
	local validation = validateDecision(decision.tool, decision.params) -- 2006
	if not validation.success then -- 2006
		return {success = false, message = validation.message, raw = rawText} -- 2008
	end -- 2008
	decision.params = validation.params -- 2010
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2011
	return decision -- 2012
end -- 1997
local function normalizeLineEndings(text) -- 2015
	local res = string.gsub(text, "\r\n", "\n") -- 2016
	res = string.gsub(res, "\r", "\n") -- 2017
	return res -- 2018
end -- 2015
local function countOccurrences(text, searchStr) -- 2021
	if searchStr == "" then -- 2021
		return 0 -- 2022
	end -- 2022
	local count = 0 -- 2023
	local pos = 0 -- 2024
	while true do -- 2024
		local idx = (string.find( -- 2026
			text, -- 2026
			searchStr, -- 2026
			math.max(pos + 1, 1), -- 2026
			true -- 2026
		) or 0) - 1 -- 2026
		if idx < 0 then -- 2026
			break -- 2027
		end -- 2027
		count = count + 1 -- 2028
		pos = idx + #searchStr -- 2029
	end -- 2029
	return count -- 2031
end -- 2021
local function replaceFirst(text, oldStr, newStr) -- 2034
	if oldStr == "" then -- 2034
		return text -- 2035
	end -- 2035
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2036
	if idx < 0 then -- 2036
		return text -- 2037
	end -- 2037
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2038
end -- 2034
local function splitLines(text) -- 2041
	return __TS__StringSplit(text, "\n") -- 2042
end -- 2041
local function getLeadingWhitespace(text) -- 2045
	local i = 0 -- 2046
	while i < #text do -- 2046
		local ch = __TS__StringAccess(text, i) -- 2048
		if ch ~= " " and ch ~= "\t" then -- 2048
			break -- 2049
		end -- 2049
		i = i + 1 -- 2050
	end -- 2050
	return __TS__StringSubstring(text, 0, i) -- 2052
end -- 2045
local function getCommonIndentPrefix(lines) -- 2055
	local common -- 2056
	do -- 2056
		local i = 0 -- 2057
		while i < #lines do -- 2057
			do -- 2057
				local line = lines[i + 1] -- 2058
				if __TS__StringTrim(line) == "" then -- 2058
					goto __continue331 -- 2059
				end -- 2059
				local indent = getLeadingWhitespace(line) -- 2060
				if common == nil then -- 2060
					common = indent -- 2062
					goto __continue331 -- 2063
				end -- 2063
				local j = 0 -- 2065
				local maxLen = math.min(#common, #indent) -- 2066
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2066
					j = j + 1 -- 2068
				end -- 2068
				common = __TS__StringSubstring(common, 0, j) -- 2070
				if common == "" then -- 2070
					break -- 2071
				end -- 2071
			end -- 2071
			::__continue331:: -- 2071
			i = i + 1 -- 2057
		end -- 2057
	end -- 2057
	return common or "" -- 2073
end -- 2055
local function removeIndentPrefix(line, indent) -- 2076
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2076
		return __TS__StringSubstring(line, #indent) -- 2078
	end -- 2078
	local lineIndent = getLeadingWhitespace(line) -- 2080
	local j = 0 -- 2081
	local maxLen = math.min(#lineIndent, #indent) -- 2082
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2082
		j = j + 1 -- 2084
	end -- 2084
	return __TS__StringSubstring(line, j) -- 2086
end -- 2076
local function dedentLines(lines) -- 2089
	local indent = getCommonIndentPrefix(lines) -- 2090
	return { -- 2091
		indent = indent, -- 2092
		lines = __TS__ArrayMap( -- 2093
			lines, -- 2093
			function(____, line) return removeIndentPrefix(line, indent) end -- 2093
		) -- 2093
	} -- 2093
end -- 2089
local function joinLines(lines) -- 2097
	return table.concat(lines, "\n") -- 2098
end -- 2097
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2101
	local contentLines = splitLines(content) -- 2106
	local oldLines = splitLines(oldStr) -- 2107
	if #oldLines == 0 then -- 2107
		return {success = false, message = "old_str not found in file"} -- 2109
	end -- 2109
	local dedentedOld = dedentLines(oldLines) -- 2111
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2112
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2113
	local matches = {} -- 2114
	do -- 2114
		local start = 0 -- 2115
		while start <= #contentLines - #oldLines do -- 2115
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2116
			local dedentedCandidate = dedentLines(candidateLines) -- 2117
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2117
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2119
			end -- 2119
			start = start + 1 -- 2115
		end -- 2115
	end -- 2115
	if #matches == 0 then -- 2115
		return {success = false, message = "old_str not found in file"} -- 2127
	end -- 2127
	if #matches > 1 then -- 2127
		return { -- 2130
			success = false, -- 2131
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2132
		} -- 2132
	end -- 2132
	local match = matches[1] -- 2135
	local rebuiltNewLines = __TS__ArrayMap( -- 2136
		dedentedNew.lines, -- 2136
		function(____, line) return line == "" and "" or match.indent .. line end -- 2136
	) -- 2136
	local ____array_36 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2136
	__TS__SparseArrayPush( -- 2136
		____array_36, -- 2136
		table.unpack(rebuiltNewLines) -- 2139
	) -- 2139
	__TS__SparseArrayPush( -- 2139
		____array_36, -- 2139
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2140
	) -- 2140
	local nextLines = {__TS__SparseArraySpread(____array_36)} -- 2137
	return { -- 2142
		success = true, -- 2142
		content = joinLines(nextLines) -- 2142
	} -- 2142
end -- 2101
local MainDecisionAgent = __TS__Class() -- 2145
MainDecisionAgent.name = "MainDecisionAgent" -- 2145
__TS__ClassExtends(MainDecisionAgent, Node) -- 2145
function MainDecisionAgent.prototype.prep(self, shared) -- 2146
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2146
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2146
			return ____awaiter_resolve(nil, {shared = shared}) -- 2146
		end -- 2146
		__TS__Await(maybeCompressHistory(shared)) -- 2151
		return ____awaiter_resolve(nil, {shared = shared}) -- 2151
	end) -- 2151
end -- 2146
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2156
	if attempt == nil then -- 2156
		attempt = 1 -- 2159
	end -- 2159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2159
		if shared.stopToken.stopped then -- 2159
			return ____awaiter_resolve( -- 2159
				nil, -- 2159
				{ -- 2163
					success = false, -- 2163
					message = getCancelledReason(shared) -- 2163
				} -- 2163
			) -- 2163
		end -- 2163
		Log( -- 2165
			"Info", -- 2165
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2165
		) -- 2165
		local tools = buildDecisionToolSchema(shared) -- 2166
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2167
		local stepId = shared.step + 1 -- 2168
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2169
		saveStepLLMDebugInput( -- 2173
			shared, -- 2173
			stepId, -- 2173
			"decision_tool_calling", -- 2173
			messages, -- 2173
			llmOptions -- 2173
		) -- 2173
		local lastStreamContent = "" -- 2174
		local lastStreamReasoning = "" -- 2175
		local res = __TS__Await(callLLMStreamAggregated( -- 2176
			messages, -- 2177
			llmOptions, -- 2178
			shared.stopToken, -- 2179
			shared.llmConfig, -- 2180
			function(response) -- 2181
				local ____opt_39 = response.choices -- 2181
				local ____opt_37 = ____opt_39 and ____opt_39[1] -- 2181
				local streamMessage = ____opt_37 and ____opt_37.message -- 2182
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2183
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2186
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2186
					return -- 2190
				end -- 2190
				lastStreamContent = nextContent -- 2192
				lastStreamReasoning = nextReasoning -- 2193
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2194
			end -- 2181
		)) -- 2181
		if shared.stopToken.stopped then -- 2181
			return ____awaiter_resolve( -- 2181
				nil, -- 2181
				{ -- 2198
					success = false, -- 2198
					message = getCancelledReason(shared) -- 2198
				} -- 2198
			) -- 2198
		end -- 2198
		if not res.success then -- 2198
			saveStepLLMDebugOutput( -- 2201
				shared, -- 2201
				stepId, -- 2201
				"decision_tool_calling", -- 2201
				res.raw or res.message, -- 2201
				{success = false} -- 2201
			) -- 2201
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2202
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2202
		end -- 2202
		saveStepLLMDebugOutput( -- 2205
			shared, -- 2205
			stepId, -- 2205
			"decision_tool_calling", -- 2205
			encodeDebugJSON(res.response), -- 2205
			{success = true} -- 2205
		) -- 2205
		local choice = res.response.choices and res.response.choices[1] -- 2206
		local message = choice and choice.message -- 2207
		local toolCalls = message and message.tool_calls -- 2208
		local toolCall = toolCalls and toolCalls[1] -- 2209
		local fn = toolCall and toolCall["function"] -- 2210
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2211
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 2214
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2217
		Log( -- 2220
			"Info", -- 2220
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2220
		) -- 2220
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2220
			if messageContent and messageContent ~= "" then -- 2220
				Log( -- 2223
					"Info", -- 2223
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2223
				) -- 2223
				return ____awaiter_resolve(nil, { -- 2223
					success = true, -- 2225
					tool = "finish", -- 2226
					params = {}, -- 2227
					reason = messageContent, -- 2228
					reasoningContent = reasoningContent, -- 2229
					directSummary = messageContent -- 2230
				}) -- 2230
			end -- 2230
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2233
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2233
		end -- 2233
		local functionName = fn.name -- 2240
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2241
		Log( -- 2242
			"Info", -- 2242
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2242
		) -- 2242
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2243
			local rawObj, err = safeJsonDecode(argsText) -- 2244
			if err ~= nil or rawObj == nil then -- 2244
				return {__error = tostring(err)} -- 2246
			end -- 2246
			return rawObj -- 2248
		end)() -- 2243
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2243
			local err = tostring(rawArgs.__error) -- 2251
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2252
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2252
		end -- 2252
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2259
		if not decision.success then -- 2259
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2261
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2261
		end -- 2261
		local validation = validateDecision(decision.tool, decision.params) -- 2268
		if not validation.success then -- 2268
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2270
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2270
		end -- 2270
		if not isToolAllowedForRole(shared.role, decision.tool) then -- 2270
			return ____awaiter_resolve(nil, {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText}) -- 2270
		end -- 2270
		decision.params = validation.params -- 2284
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2285
		decision.reason = messageContent -- 2286
		decision.reasoningContent = reasoningContent -- 2287
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2288
		return ____awaiter_resolve(nil, decision) -- 2288
	end) -- 2288
end -- 2156
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2292
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2292
		Log( -- 2297
			"Info", -- 2297
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2297
		) -- 2297
		local lastError = initialError -- 2298
		local candidateRaw = "" -- 2299
		do -- 2299
			local attempt = 0 -- 2300
			while attempt < shared.llmMaxTry do -- 2300
				do -- 2300
					Log( -- 2301
						"Info", -- 2301
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2301
					) -- 2301
					local messages = buildXmlRepairMessages( -- 2302
						shared, -- 2303
						originalRaw, -- 2304
						candidateRaw, -- 2305
						lastError, -- 2306
						attempt + 1 -- 2307
					) -- 2307
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2309
					if shared.stopToken.stopped then -- 2309
						return ____awaiter_resolve( -- 2309
							nil, -- 2309
							{ -- 2311
								success = false, -- 2311
								message = getCancelledReason(shared) -- 2311
							} -- 2311
						) -- 2311
					end -- 2311
					if not llmRes.success then -- 2311
						lastError = llmRes.message -- 2314
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2315
						goto __continue368 -- 2316
					end -- 2316
					candidateRaw = llmRes.text -- 2318
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2319
					if decision.success then -- 2319
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2321
						return ____awaiter_resolve(nil, decision) -- 2321
					end -- 2321
					lastError = decision.message -- 2324
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2325
				end -- 2325
				::__continue368:: -- 2325
				attempt = attempt + 1 -- 2300
			end -- 2300
		end -- 2300
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2327
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2327
	end) -- 2327
end -- 2292
function MainDecisionAgent.prototype.exec(self, input) -- 2335
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2335
		local shared = input.shared -- 2336
		if shared.stopToken.stopped then -- 2336
			return ____awaiter_resolve( -- 2336
				nil, -- 2336
				{ -- 2338
					success = false, -- 2338
					message = getCancelledReason(shared) -- 2338
				} -- 2338
			) -- 2338
		end -- 2338
		if shared.step >= shared.maxSteps then -- 2338
			Log( -- 2341
				"Warn", -- 2341
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2341
			) -- 2341
			return ____awaiter_resolve( -- 2341
				nil, -- 2341
				{ -- 2342
					success = false, -- 2342
					message = getMaxStepsReachedReason(shared) -- 2342
				} -- 2342
			) -- 2342
		end -- 2342
		if shared.decisionMode == "tool_calling" then -- 2342
			Log( -- 2346
				"Info", -- 2346
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2346
			) -- 2346
			local lastError = "tool calling validation failed" -- 2347
			local lastRaw = "" -- 2348
			do -- 2348
				local attempt = 0 -- 2349
				while attempt < shared.llmMaxTry do -- 2349
					Log( -- 2350
						"Info", -- 2350
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2350
					) -- 2350
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2351
					if shared.stopToken.stopped then -- 2351
						return ____awaiter_resolve( -- 2351
							nil, -- 2351
							{ -- 2358
								success = false, -- 2358
								message = getCancelledReason(shared) -- 2358
							} -- 2358
						) -- 2358
					end -- 2358
					if decision.success then -- 2358
						return ____awaiter_resolve(nil, decision) -- 2358
					end -- 2358
					lastError = decision.message -- 2363
					lastRaw = decision.raw or "" -- 2364
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2365
					attempt = attempt + 1 -- 2349
				end -- 2349
			end -- 2349
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2367
			return ____awaiter_resolve( -- 2367
				nil, -- 2367
				{ -- 2368
					success = false, -- 2368
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2368
				} -- 2368
			) -- 2368
		end -- 2368
		local lastError = "xml validation failed" -- 2371
		local lastRaw = "" -- 2372
		do -- 2372
			local attempt = 0 -- 2373
			while attempt < shared.llmMaxTry do -- 2373
				do -- 2373
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2374
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2382
					if shared.stopToken.stopped then -- 2382
						return ____awaiter_resolve( -- 2382
							nil, -- 2382
							{ -- 2384
								success = false, -- 2384
								message = getCancelledReason(shared) -- 2384
							} -- 2384
						) -- 2384
					end -- 2384
					if not llmRes.success then -- 2384
						lastError = llmRes.message -- 2387
						lastRaw = llmRes.text or "" -- 2388
						goto __continue381 -- 2389
					end -- 2389
					lastRaw = llmRes.text -- 2391
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2392
					if decision.success then -- 2392
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2392
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2395
							return ____awaiter_resolve( -- 2395
								nil, -- 2395
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2396
							) -- 2396
						end -- 2396
						return ____awaiter_resolve(nil, decision) -- 2396
					end -- 2396
					lastError = decision.message -- 2400
					return ____awaiter_resolve( -- 2400
						nil, -- 2400
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2401
					) -- 2401
				end -- 2401
				::__continue381:: -- 2401
				attempt = attempt + 1 -- 2373
			end -- 2373
		end -- 2373
		return ____awaiter_resolve( -- 2373
			nil, -- 2373
			{ -- 2403
				success = false, -- 2403
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2403
			} -- 2403
		) -- 2403
	end) -- 2403
end -- 2335
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2406
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2406
		local result = execRes -- 2407
		if not result.success then -- 2407
			if shared.stopToken.stopped then -- 2407
				shared.error = getCancelledReason(shared) -- 2410
				shared.done = true -- 2411
				return ____awaiter_resolve(nil, "done") -- 2411
			end -- 2411
			shared.error = result.message -- 2414
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2415
			shared.done = true -- 2416
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2417
			persistHistoryState(shared) -- 2421
			return ____awaiter_resolve(nil, "done") -- 2421
		end -- 2421
		if result.directSummary and result.directSummary ~= "" then -- 2421
			shared.response = result.directSummary -- 2425
			shared.done = true -- 2426
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2427
			persistHistoryState(shared) -- 2432
			return ____awaiter_resolve(nil, "done") -- 2432
		end -- 2432
		if result.tool == "finish" then -- 2432
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2436
			shared.response = finalMessage -- 2437
			shared.done = true -- 2438
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2439
			persistHistoryState(shared) -- 2444
			return ____awaiter_resolve(nil, "done") -- 2444
		end -- 2444
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2447
		shared.step = shared.step + 1 -- 2448
		local step = shared.step -- 2449
		emitAgentEvent(shared, { -- 2450
			type = "decision_made", -- 2451
			sessionId = shared.sessionId, -- 2452
			taskId = shared.taskId, -- 2453
			step = step, -- 2454
			tool = result.tool, -- 2455
			reason = result.reason, -- 2456
			reasoningContent = result.reasoningContent, -- 2457
			params = result.params -- 2458
		}) -- 2458
		local ____shared_history_45 = shared.history -- 2458
		____shared_history_45[#____shared_history_45 + 1] = { -- 2460
			step = step, -- 2461
			toolCallId = toolCallId, -- 2462
			tool = result.tool, -- 2463
			reason = result.reason or "", -- 2464
			reasoningContent = result.reasoningContent, -- 2465
			params = result.params, -- 2466
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2467
		} -- 2467
		appendConversationMessage( -- 2469
			shared, -- 2469
			{ -- 2469
				role = "assistant", -- 2470
				content = result.reason or "", -- 2471
				reasoning_content = result.reasoningContent, -- 2472
				tool_calls = {{ -- 2473
					id = toolCallId, -- 2474
					type = "function", -- 2475
					["function"] = { -- 2476
						name = result.tool, -- 2477
						arguments = toJson(result.params) -- 2478
					} -- 2478
				}} -- 2478
			} -- 2478
		) -- 2478
		persistHistoryState(shared) -- 2482
		return ____awaiter_resolve(nil, result.tool) -- 2482
	end) -- 2482
end -- 2406
local ReadFileAction = __TS__Class() -- 2487
ReadFileAction.name = "ReadFileAction" -- 2487
__TS__ClassExtends(ReadFileAction, Node) -- 2487
function ReadFileAction.prototype.prep(self, shared) -- 2488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2488
		local last = shared.history[#shared.history] -- 2489
		if not last then -- 2489
			error( -- 2490
				__TS__New(Error, "no history"), -- 2490
				0 -- 2490
			) -- 2490
		end -- 2490
		emitAgentStartEvent(shared, last) -- 2491
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2492
		if __TS__StringTrim(path) == "" then -- 2492
			error( -- 2495
				__TS__New(Error, "missing path"), -- 2495
				0 -- 2495
			) -- 2495
		end -- 2495
		local ____path_48 = path -- 2497
		local ____shared_workingDir_49 = shared.workingDir -- 2499
		local ____temp_50 = shared.useChineseResponse and "zh" or "en" -- 2500
		local ____last_params_startLine_46 = last.params.startLine -- 2501
		if ____last_params_startLine_46 == nil then -- 2501
			____last_params_startLine_46 = 1 -- 2501
		end -- 2501
		local ____TS__Number_result_51 = __TS__Number(____last_params_startLine_46) -- 2501
		local ____last_params_endLine_47 = last.params.endLine -- 2502
		if ____last_params_endLine_47 == nil then -- 2502
			____last_params_endLine_47 = READ_FILE_DEFAULT_LIMIT -- 2502
		end -- 2502
		return ____awaiter_resolve( -- 2502
			nil, -- 2502
			{ -- 2496
				path = ____path_48, -- 2497
				tool = "read_file", -- 2498
				workDir = ____shared_workingDir_49, -- 2499
				docLanguage = ____temp_50, -- 2500
				startLine = ____TS__Number_result_51, -- 2501
				endLine = __TS__Number(____last_params_endLine_47) -- 2502
			} -- 2502
		) -- 2502
	end) -- 2502
end -- 2488
function ReadFileAction.prototype.exec(self, input) -- 2506
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2506
		return ____awaiter_resolve( -- 2506
			nil, -- 2506
			Tools.readFile( -- 2507
				input.workDir, -- 2508
				input.path, -- 2509
				__TS__Number(input.startLine or 1), -- 2510
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2511
				input.docLanguage -- 2512
			) -- 2512
		) -- 2512
	end) -- 2512
end -- 2506
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2516
		local result = execRes -- 2517
		local last = shared.history[#shared.history] -- 2518
		if last ~= nil then -- 2518
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2520
			appendToolResultMessage(shared, last) -- 2521
			emitAgentFinishEvent(shared, last) -- 2522
		end -- 2522
		persistHistoryState(shared) -- 2524
		__TS__Await(maybeCompressHistory(shared)) -- 2525
		persistHistoryState(shared) -- 2526
		return ____awaiter_resolve(nil, "main") -- 2526
	end) -- 2526
end -- 2516
local SearchFilesAction = __TS__Class() -- 2531
SearchFilesAction.name = "SearchFilesAction" -- 2531
__TS__ClassExtends(SearchFilesAction, Node) -- 2531
function SearchFilesAction.prototype.prep(self, shared) -- 2532
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2532
		local last = shared.history[#shared.history] -- 2533
		if not last then -- 2533
			error( -- 2534
				__TS__New(Error, "no history"), -- 2534
				0 -- 2534
			) -- 2534
		end -- 2534
		emitAgentStartEvent(shared, last) -- 2535
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2535
	end) -- 2535
end -- 2532
function SearchFilesAction.prototype.exec(self, input) -- 2539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2539
		local params = input.params -- 2540
		local ____Tools_searchFiles_65 = Tools.searchFiles -- 2541
		local ____input_workDir_58 = input.workDir -- 2542
		local ____temp_59 = params.path or "" -- 2543
		local ____temp_60 = params.pattern or "" -- 2544
		local ____params_globs_61 = params.globs -- 2545
		local ____params_useRegex_62 = params.useRegex -- 2546
		local ____params_caseSensitive_63 = params.caseSensitive -- 2547
		local ____math_max_54 = math.max -- 2550
		local ____math_floor_53 = math.floor -- 2550
		local ____params_limit_52 = params.limit -- 2550
		if ____params_limit_52 == nil then -- 2550
			____params_limit_52 = SEARCH_FILES_LIMIT_DEFAULT -- 2550
		end -- 2550
		local ____math_max_54_result_64 = ____math_max_54( -- 2550
			1, -- 2550
			____math_floor_53(__TS__Number(____params_limit_52)) -- 2550
		) -- 2550
		local ____math_max_57 = math.max -- 2551
		local ____math_floor_56 = math.floor -- 2551
		local ____params_offset_55 = params.offset -- 2551
		if ____params_offset_55 == nil then -- 2551
			____params_offset_55 = 0 -- 2551
		end -- 2551
		local result = __TS__Await(____Tools_searchFiles_65({ -- 2541
			workDir = ____input_workDir_58, -- 2542
			path = ____temp_59, -- 2543
			pattern = ____temp_60, -- 2544
			globs = ____params_globs_61, -- 2545
			useRegex = ____params_useRegex_62, -- 2546
			caseSensitive = ____params_caseSensitive_63, -- 2547
			includeContent = true, -- 2548
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2549
			limit = ____math_max_54_result_64, -- 2550
			offset = ____math_max_57( -- 2551
				0, -- 2551
				____math_floor_56(__TS__Number(____params_offset_55)) -- 2551
			), -- 2551
			groupByFile = params.groupByFile == true -- 2552
		})) -- 2552
		return ____awaiter_resolve(nil, result) -- 2552
	end) -- 2552
end -- 2539
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2557
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2557
		local last = shared.history[#shared.history] -- 2558
		if last ~= nil then -- 2558
			local result = execRes -- 2560
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2561
			appendToolResultMessage(shared, last) -- 2562
			emitAgentFinishEvent(shared, last) -- 2563
		end -- 2563
		persistHistoryState(shared) -- 2565
		__TS__Await(maybeCompressHistory(shared)) -- 2566
		persistHistoryState(shared) -- 2567
		return ____awaiter_resolve(nil, "main") -- 2567
	end) -- 2567
end -- 2557
local SearchDoraAPIAction = __TS__Class() -- 2572
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2572
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2572
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2573
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2573
		local last = shared.history[#shared.history] -- 2574
		if not last then -- 2574
			error( -- 2575
				__TS__New(Error, "no history"), -- 2575
				0 -- 2575
			) -- 2575
		end -- 2575
		emitAgentStartEvent(shared, last) -- 2576
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2576
	end) -- 2576
end -- 2573
function SearchDoraAPIAction.prototype.exec(self, input) -- 2580
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2580
		local params = input.params -- 2581
		local ____Tools_searchDoraAPI_73 = Tools.searchDoraAPI -- 2582
		local ____temp_69 = params.pattern or "" -- 2583
		local ____temp_70 = params.docSource or "api" -- 2584
		local ____temp_71 = input.useChineseResponse and "zh" or "en" -- 2585
		local ____temp_72 = params.programmingLanguage or "ts" -- 2586
		local ____math_min_68 = math.min -- 2587
		local ____math_max_67 = math.max -- 2587
		local ____params_limit_66 = params.limit -- 2587
		if ____params_limit_66 == nil then -- 2587
			____params_limit_66 = 8 -- 2587
		end -- 2587
		local result = __TS__Await(____Tools_searchDoraAPI_73({ -- 2582
			pattern = ____temp_69, -- 2583
			docSource = ____temp_70, -- 2584
			docLanguage = ____temp_71, -- 2585
			programmingLanguage = ____temp_72, -- 2586
			limit = ____math_min_68( -- 2587
				SEARCH_DORA_API_LIMIT_MAX, -- 2587
				____math_max_67( -- 2587
					1, -- 2587
					__TS__Number(____params_limit_66) -- 2587
				) -- 2587
			), -- 2587
			useRegex = params.useRegex, -- 2588
			caseSensitive = false, -- 2589
			includeContent = true, -- 2590
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2591
		})) -- 2591
		return ____awaiter_resolve(nil, result) -- 2591
	end) -- 2591
end -- 2580
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2596
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2596
		local last = shared.history[#shared.history] -- 2597
		if last ~= nil then -- 2597
			local result = execRes -- 2599
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2600
			appendToolResultMessage(shared, last) -- 2601
			emitAgentFinishEvent(shared, last) -- 2602
		end -- 2602
		persistHistoryState(shared) -- 2604
		__TS__Await(maybeCompressHistory(shared)) -- 2605
		persistHistoryState(shared) -- 2606
		return ____awaiter_resolve(nil, "main") -- 2606
	end) -- 2606
end -- 2596
local ListFilesAction = __TS__Class() -- 2611
ListFilesAction.name = "ListFilesAction" -- 2611
__TS__ClassExtends(ListFilesAction, Node) -- 2611
function ListFilesAction.prototype.prep(self, shared) -- 2612
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2612
		local last = shared.history[#shared.history] -- 2613
		if not last then -- 2613
			error( -- 2614
				__TS__New(Error, "no history"), -- 2614
				0 -- 2614
			) -- 2614
		end -- 2614
		emitAgentStartEvent(shared, last) -- 2615
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2615
	end) -- 2615
end -- 2612
function ListFilesAction.prototype.exec(self, input) -- 2619
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2619
		local params = input.params -- 2620
		local ____Tools_listFiles_80 = Tools.listFiles -- 2621
		local ____input_workDir_77 = input.workDir -- 2622
		local ____temp_78 = params.path or "" -- 2623
		local ____params_globs_79 = params.globs -- 2624
		local ____math_max_76 = math.max -- 2625
		local ____math_floor_75 = math.floor -- 2625
		local ____params_maxEntries_74 = params.maxEntries -- 2625
		if ____params_maxEntries_74 == nil then -- 2625
			____params_maxEntries_74 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2625
		end -- 2625
		local result = ____Tools_listFiles_80({ -- 2621
			workDir = ____input_workDir_77, -- 2622
			path = ____temp_78, -- 2623
			globs = ____params_globs_79, -- 2624
			maxEntries = ____math_max_76( -- 2625
				1, -- 2625
				____math_floor_75(__TS__Number(____params_maxEntries_74)) -- 2625
			) -- 2625
		}) -- 2625
		return ____awaiter_resolve(nil, result) -- 2625
	end) -- 2625
end -- 2619
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2630
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2630
		local last = shared.history[#shared.history] -- 2631
		if last ~= nil then -- 2631
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2633
			appendToolResultMessage(shared, last) -- 2634
			emitAgentFinishEvent(shared, last) -- 2635
		end -- 2635
		persistHistoryState(shared) -- 2637
		__TS__Await(maybeCompressHistory(shared)) -- 2638
		persistHistoryState(shared) -- 2639
		return ____awaiter_resolve(nil, "main") -- 2639
	end) -- 2639
end -- 2630
local DeleteFileAction = __TS__Class() -- 2644
DeleteFileAction.name = "DeleteFileAction" -- 2644
__TS__ClassExtends(DeleteFileAction, Node) -- 2644
function DeleteFileAction.prototype.prep(self, shared) -- 2645
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2645
		local last = shared.history[#shared.history] -- 2646
		if not last then -- 2646
			error( -- 2647
				__TS__New(Error, "no history"), -- 2647
				0 -- 2647
			) -- 2647
		end -- 2647
		emitAgentStartEvent(shared, last) -- 2648
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2649
		if __TS__StringTrim(targetFile) == "" then -- 2649
			error( -- 2652
				__TS__New(Error, "missing target_file"), -- 2652
				0 -- 2652
			) -- 2652
		end -- 2652
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2652
	end) -- 2652
end -- 2645
function DeleteFileAction.prototype.exec(self, input) -- 2656
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2656
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2657
		if not result.success then -- 2657
			return ____awaiter_resolve(nil, result) -- 2657
		end -- 2657
		return ____awaiter_resolve(nil, { -- 2657
			success = true, -- 2665
			changed = true, -- 2666
			mode = "delete", -- 2667
			checkpointId = result.checkpointId, -- 2668
			checkpointSeq = result.checkpointSeq, -- 2669
			files = {{path = input.targetFile, op = "delete"}} -- 2670
		}) -- 2670
	end) -- 2670
end -- 2656
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2674
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2674
		local last = shared.history[#shared.history] -- 2675
		if last ~= nil then -- 2675
			last.result = execRes -- 2677
			appendToolResultMessage(shared, last) -- 2678
			emitAgentFinishEvent(shared, last) -- 2679
			local result = last.result -- 2680
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2680
				emitAgentEvent(shared, { -- 2685
					type = "checkpoint_created", -- 2686
					sessionId = shared.sessionId, -- 2687
					taskId = shared.taskId, -- 2688
					step = last.step, -- 2689
					tool = "delete_file", -- 2690
					checkpointId = result.checkpointId, -- 2691
					checkpointSeq = result.checkpointSeq, -- 2692
					files = result.files -- 2693
				}) -- 2693
			end -- 2693
		end -- 2693
		persistHistoryState(shared) -- 2697
		__TS__Await(maybeCompressHistory(shared)) -- 2698
		persistHistoryState(shared) -- 2699
		return ____awaiter_resolve(nil, "main") -- 2699
	end) -- 2699
end -- 2674
local BuildAction = __TS__Class() -- 2704
BuildAction.name = "BuildAction" -- 2704
__TS__ClassExtends(BuildAction, Node) -- 2704
function BuildAction.prototype.prep(self, shared) -- 2705
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2705
		local last = shared.history[#shared.history] -- 2706
		if not last then -- 2706
			error( -- 2707
				__TS__New(Error, "no history"), -- 2707
				0 -- 2707
			) -- 2707
		end -- 2707
		emitAgentStartEvent(shared, last) -- 2708
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2708
	end) -- 2708
end -- 2705
function BuildAction.prototype.exec(self, input) -- 2712
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2712
		local params = input.params -- 2713
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2714
		return ____awaiter_resolve(nil, result) -- 2714
	end) -- 2714
end -- 2712
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2721
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2721
		local last = shared.history[#shared.history] -- 2722
		if last ~= nil then -- 2722
			last.result = execRes -- 2724
			appendToolResultMessage(shared, last) -- 2725
			emitAgentFinishEvent(shared, last) -- 2726
		end -- 2726
		persistHistoryState(shared) -- 2728
		__TS__Await(maybeCompressHistory(shared)) -- 2729
		persistHistoryState(shared) -- 2730
		return ____awaiter_resolve(nil, "main") -- 2730
	end) -- 2730
end -- 2721
local SpawnSubAgentAction = __TS__Class() -- 2735
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2735
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2735
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2736
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2736
		local last = shared.history[#shared.history] -- 2745
		if not last then -- 2745
			error( -- 2746
				__TS__New(Error, "no history"), -- 2746
				0 -- 2746
			) -- 2746
		end -- 2746
		emitAgentStartEvent(shared, last) -- 2747
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2748
			last.params.filesHint, -- 2749
			function(____, item) return type(item) == "string" end -- 2749
		) or nil -- 2749
		return ____awaiter_resolve( -- 2749
			nil, -- 2749
			{ -- 2751
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2752
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2753
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2754
				filesHint = filesHint, -- 2755
				sessionId = shared.sessionId, -- 2756
				projectRoot = shared.workingDir, -- 2757
				spawnSubAgent = shared.spawnSubAgent -- 2758
			} -- 2758
		) -- 2758
	end) -- 2758
end -- 2736
function SpawnSubAgentAction.prototype.exec(self, input) -- 2762
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2762
		if not input.spawnSubAgent then -- 2762
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2762
		end -- 2762
		if input.sessionId == nil or input.sessionId <= 0 then -- 2762
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2762
		end -- 2762
		local ____Log_86 = Log -- 2777
		local ____temp_83 = #input.title -- 2777
		local ____temp_84 = #input.prompt -- 2777
		local ____temp_85 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2777
		local ____opt_81 = input.filesHint -- 2777
		____Log_86( -- 2777
			"Info", -- 2777
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_83)) .. " prompt_len=") .. tostring(____temp_84)) .. " expected_len=") .. tostring(____temp_85)) .. " files_hint_count=") .. tostring(____opt_81 and #____opt_81 or 0) -- 2777
		) -- 2777
		local result = __TS__Await(input:spawnSubAgent({ -- 2778
			parentSessionId = input.sessionId, -- 2779
			projectRoot = input.projectRoot, -- 2780
			title = input.title, -- 2781
			prompt = input.prompt, -- 2782
			expectedOutput = input.expectedOutput, -- 2783
			filesHint = input.filesHint -- 2784
		})) -- 2784
		if not result.success then -- 2784
			return ____awaiter_resolve(nil, result) -- 2784
		end -- 2784
		return ____awaiter_resolve(nil, { -- 2784
			success = true, -- 2790
			sessionId = result.sessionId, -- 2791
			taskId = result.taskId, -- 2792
			title = result.title, -- 2793
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 2794
		}) -- 2794
	end) -- 2794
end -- 2762
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 2798
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
local ListSubAgentsAction = __TS__Class() -- 2812
ListSubAgentsAction.name = "ListSubAgentsAction" -- 2812
__TS__ClassExtends(ListSubAgentsAction, Node) -- 2812
function ListSubAgentsAction.prototype.prep(self, shared) -- 2813
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2813
		local last = shared.history[#shared.history] -- 2822
		if not last then -- 2822
			error( -- 2823
				__TS__New(Error, "no history"), -- 2823
				0 -- 2823
			) -- 2823
		end -- 2823
		emitAgentStartEvent(shared, last) -- 2824
		return ____awaiter_resolve( -- 2824
			nil, -- 2824
			{ -- 2825
				sessionId = shared.sessionId, -- 2826
				projectRoot = shared.workingDir, -- 2827
				status = type(last.params.status) == "string" and last.params.status or nil, -- 2828
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 2829
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 2830
				query = type(last.params.query) == "string" and last.params.query or nil, -- 2831
				listSubAgents = shared.listSubAgents -- 2832
			} -- 2832
		) -- 2832
	end) -- 2832
end -- 2813
function ListSubAgentsAction.prototype.exec(self, input) -- 2836
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2836
		if not input.listSubAgents then -- 2836
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 2836
		end -- 2836
		if input.sessionId == nil or input.sessionId <= 0 then -- 2836
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 2836
		end -- 2836
		local result = __TS__Await(input:listSubAgents({ -- 2851
			sessionId = input.sessionId, -- 2852
			projectRoot = input.projectRoot, -- 2853
			status = input.status, -- 2854
			limit = input.limit, -- 2855
			offset = input.offset, -- 2856
			query = input.query -- 2857
		})) -- 2857
		return ____awaiter_resolve(nil, result) -- 2857
	end) -- 2857
end -- 2836
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 2862
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2862
		local last = shared.history[#shared.history] -- 2863
		if last ~= nil then -- 2863
			last.result = execRes -- 2865
			appendToolResultMessage(shared, last) -- 2866
			emitAgentFinishEvent(shared, last) -- 2867
		end -- 2867
		persistHistoryState(shared) -- 2869
		__TS__Await(maybeCompressHistory(shared)) -- 2870
		persistHistoryState(shared) -- 2871
		return ____awaiter_resolve(nil, "main") -- 2871
	end) -- 2871
end -- 2862
local EditFileAction = __TS__Class() -- 2876
EditFileAction.name = "EditFileAction" -- 2876
__TS__ClassExtends(EditFileAction, Node) -- 2876
function EditFileAction.prototype.prep(self, shared) -- 2877
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2877
		local last = shared.history[#shared.history] -- 2878
		if not last then -- 2878
			error( -- 2879
				__TS__New(Error, "no history"), -- 2879
				0 -- 2879
			) -- 2879
		end -- 2879
		emitAgentStartEvent(shared, last) -- 2880
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2881
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2884
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2885
		if __TS__StringTrim(path) == "" then -- 2885
			error( -- 2886
				__TS__New(Error, "missing path"), -- 2886
				0 -- 2886
			) -- 2886
		end -- 2886
		return ____awaiter_resolve(nil, { -- 2886
			path = path, -- 2887
			oldStr = oldStr, -- 2887
			newStr = newStr, -- 2887
			taskId = shared.taskId, -- 2887
			workDir = shared.workingDir -- 2887
		}) -- 2887
	end) -- 2887
end -- 2877
function EditFileAction.prototype.exec(self, input) -- 2890
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2890
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2891
		if not readRes.success then -- 2891
			if input.oldStr ~= "" then -- 2891
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2891
			end -- 2891
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2896
			if not createRes.success then -- 2896
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2896
			end -- 2896
			return ____awaiter_resolve(nil, { -- 2896
				success = true, -- 2904
				changed = true, -- 2905
				mode = "create", -- 2906
				checkpointId = createRes.checkpointId, -- 2907
				checkpointSeq = createRes.checkpointSeq, -- 2908
				files = {{path = input.path, op = "create"}} -- 2909
			}) -- 2909
		end -- 2909
		if input.oldStr == "" then -- 2909
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2913
			if not overwriteRes.success then -- 2913
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2913
			end -- 2913
			return ____awaiter_resolve(nil, { -- 2913
				success = true, -- 2921
				changed = true, -- 2922
				mode = "overwrite", -- 2923
				checkpointId = overwriteRes.checkpointId, -- 2924
				checkpointSeq = overwriteRes.checkpointSeq, -- 2925
				files = {{path = input.path, op = "write"}} -- 2926
			}) -- 2926
		end -- 2926
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2931
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2932
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2933
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2936
		if occurrences == 0 then -- 2936
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2938
			if not indentTolerant.success then -- 2938
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2938
			end -- 2938
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2942
			if not applyRes.success then -- 2942
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2942
			end -- 2942
			return ____awaiter_resolve(nil, { -- 2942
				success = true, -- 2950
				changed = true, -- 2951
				mode = "replace_indent_tolerant", -- 2952
				checkpointId = applyRes.checkpointId, -- 2953
				checkpointSeq = applyRes.checkpointSeq, -- 2954
				files = {{path = input.path, op = "write"}} -- 2955
			}) -- 2955
		end -- 2955
		if occurrences > 1 then -- 2955
			return ____awaiter_resolve( -- 2955
				nil, -- 2955
				{ -- 2959
					success = false, -- 2959
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2959
				} -- 2959
			) -- 2959
		end -- 2959
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2963
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2964
		if not applyRes.success then -- 2964
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2964
		end -- 2964
		return ____awaiter_resolve(nil, { -- 2964
			success = true, -- 2972
			changed = true, -- 2973
			mode = "replace", -- 2974
			checkpointId = applyRes.checkpointId, -- 2975
			checkpointSeq = applyRes.checkpointSeq, -- 2976
			files = {{path = input.path, op = "write"}} -- 2977
		}) -- 2977
	end) -- 2977
end -- 2890
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2981
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2981
		local last = shared.history[#shared.history] -- 2982
		if last ~= nil then -- 2982
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2984
			last.result = execRes -- 2985
			appendToolResultMessage(shared, last) -- 2986
			emitAgentFinishEvent(shared, last) -- 2987
			local result = last.result -- 2988
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2988
				emitAgentEvent(shared, { -- 2993
					type = "checkpoint_created", -- 2994
					sessionId = shared.sessionId, -- 2995
					taskId = shared.taskId, -- 2996
					step = last.step, -- 2997
					tool = last.tool, -- 2998
					checkpointId = result.checkpointId, -- 2999
					checkpointSeq = result.checkpointSeq, -- 3000
					files = result.files -- 3001
				}) -- 3001
			end -- 3001
		end -- 3001
		persistHistoryState(shared) -- 3005
		__TS__Await(maybeCompressHistory(shared)) -- 3006
		persistHistoryState(shared) -- 3007
		return ____awaiter_resolve(nil, "main") -- 3007
	end) -- 3007
end -- 2981
local EndNode = __TS__Class() -- 3012
EndNode.name = "EndNode" -- 3012
__TS__ClassExtends(EndNode, Node) -- 3012
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3013
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3013
		return ____awaiter_resolve(nil, nil) -- 3013
	end) -- 3013
end -- 3013
local CodingAgentFlow = __TS__Class() -- 3018
CodingAgentFlow.name = "CodingAgentFlow" -- 3018
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3018
function CodingAgentFlow.prototype.____constructor(self, role) -- 3019
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3020
	local read = __TS__New(ReadFileAction, 1, 0) -- 3021
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3022
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3023
	local list = __TS__New(ListFilesAction, 1, 0) -- 3024
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3025
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3026
	local build = __TS__New(BuildAction, 1, 0) -- 3027
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3028
	local edit = __TS__New(EditFileAction, 1, 0) -- 3029
	local done = __TS__New(EndNode, 1, 0) -- 3030
	main:on("grep_files", search) -- 3032
	main:on("search_dora_api", searchDora) -- 3033
	main:on("glob_files", list) -- 3034
	if role == "main" then -- 3034
		main:on("read_file", read) -- 3036
		main:on("list_sub_agents", listSub) -- 3037
		main:on("spawn_sub_agent", spawn) -- 3038
	else -- 3038
		main:on("read_file", read) -- 3040
		main:on("delete_file", del) -- 3041
		main:on("build", build) -- 3042
		main:on("edit_file", edit) -- 3043
	end -- 3043
	main:on("done", done) -- 3045
	search:on("main", main) -- 3047
	searchDora:on("main", main) -- 3048
	list:on("main", main) -- 3049
	listSub:on("main", main) -- 3050
	spawn:on("main", main) -- 3051
	read:on("main", main) -- 3052
	del:on("main", main) -- 3053
	build:on("main", main) -- 3054
	edit:on("main", main) -- 3055
	Flow.prototype.____constructor(self, main) -- 3057
end -- 3019
local function runCodingAgentAsync(options) -- 3079
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3079
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3079
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3079
		end -- 3079
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3083
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3084
		if not llmConfigRes.success then -- 3084
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3084
		end -- 3084
		local llmConfig = llmConfigRes.config -- 3090
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3091
		if not taskRes.success then -- 3091
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3091
		end -- 3091
		local compressor = __TS__New(MemoryCompressor, { -- 3098
			compressionThreshold = 0.8, -- 3099
			compressionTargetThreshold = 0.5, -- 3100
			maxCompressionRounds = 3, -- 3101
			projectDir = options.workDir, -- 3102
			llmConfig = llmConfig, -- 3103
			promptPack = options.promptPack, -- 3104
			scope = options.memoryScope -- 3105
		}) -- 3105
		local persistedSession = compressor:getStorage():readSessionState() -- 3107
		local promptPack = compressor:getPromptPack() -- 3108
		local shared = { -- 3110
			sessionId = options.sessionId, -- 3111
			taskId = taskRes.taskId, -- 3112
			role = options.role or "main", -- 3113
			maxSteps = math.max( -- 3114
				1, -- 3114
				math.floor(options.maxSteps or 50) -- 3114
			), -- 3114
			llmMaxTry = math.max( -- 3115
				1, -- 3115
				math.floor(options.llmMaxTry or 5) -- 3115
			), -- 3115
			step = 0, -- 3116
			done = false, -- 3117
			stopToken = options.stopToken or ({stopped = false}), -- 3118
			response = "", -- 3119
			userQuery = normalizedPrompt, -- 3120
			workingDir = options.workDir, -- 3121
			useChineseResponse = options.useChineseResponse == true, -- 3122
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3123
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 3126
			llmConfig = llmConfig, -- 3131
			onEvent = options.onEvent, -- 3132
			promptPack = promptPack, -- 3133
			history = {}, -- 3134
			messages = persistedSession.messages, -- 3135
			memory = {compressor = compressor}, -- 3137
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3141
			spawnSubAgent = options.spawnSubAgent, -- 3146
			listSubAgents = options.listSubAgents -- 3147
		} -- 3147
		local ____try = __TS__AsyncAwaiter(function() -- 3147
			emitAgentEvent(shared, { -- 3151
				type = "task_started", -- 3152
				sessionId = shared.sessionId, -- 3153
				taskId = shared.taskId, -- 3154
				prompt = shared.userQuery, -- 3155
				workDir = shared.workingDir, -- 3156
				maxSteps = shared.maxSteps -- 3157
			}) -- 3157
			if shared.stopToken.stopped then -- 3157
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3160
				return ____awaiter_resolve( -- 3160
					nil, -- 3160
					emitAgentTaskFinishEvent( -- 3161
						shared, -- 3161
						false, -- 3161
						getCancelledReason(shared) -- 3161
					) -- 3161
				) -- 3161
			end -- 3161
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3163
			local promptCommand = getPromptCommand(shared.userQuery) -- 3164
			if promptCommand == "reset" then -- 3164
				return ____awaiter_resolve( -- 3164
					nil, -- 3164
					resetSessionHistory(shared) -- 3166
				) -- 3166
			end -- 3166
			if promptCommand == "compact" then -- 3166
				return ____awaiter_resolve( -- 3166
					nil, -- 3166
					__TS__Await(compactAllHistory(shared)) -- 3169
				) -- 3169
			end -- 3169
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3171
			persistHistoryState(shared) -- 3175
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3176
			__TS__Await(flow:run(shared)) -- 3177
			if shared.stopToken.stopped then -- 3177
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3179
				return ____awaiter_resolve( -- 3179
					nil, -- 3179
					emitAgentTaskFinishEvent( -- 3180
						shared, -- 3180
						false, -- 3180
						getCancelledReason(shared) -- 3180
					) -- 3180
				) -- 3180
			end -- 3180
			if shared.error then -- 3180
				return ____awaiter_resolve( -- 3180
					nil, -- 3180
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3183
				) -- 3183
			end -- 3183
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3186
			return ____awaiter_resolve( -- 3186
				nil, -- 3186
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3187
			) -- 3187
		end) -- 3187
		__TS__Await(____try.catch( -- 3150
			____try, -- 3150
			function(____, e) -- 3150
				return ____awaiter_resolve( -- 3150
					nil, -- 3150
					finalizeAgentFailure( -- 3190
						shared, -- 3190
						tostring(e) -- 3190
					) -- 3190
				) -- 3190
			end -- 3190
		)) -- 3190
	end) -- 3190
end -- 3079
function ____exports.runCodingAgent(options, callback) -- 3194
	local ____self_87 = runCodingAgentAsync(options) -- 3194
	____self_87["then"]( -- 3194
		____self_87, -- 3194
		function(____, result) return callback(result) end -- 3195
	) -- 3195
end -- 3194
return ____exports -- 3194