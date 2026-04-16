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
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
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
function emitAgentEvent(shared, event) -- 680
	if shared.onEvent then -- 680
		do -- 680
			local function ____catch(____error) -- 680
				Log( -- 685
					"Error", -- 685
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 685
				) -- 685
			end -- 685
			local ____try, ____hasReturned = pcall(function() -- 685
				shared:onEvent(event) -- 683
			end) -- 683
			if not ____try then -- 683
				____catch(____hasReturned) -- 683
			end -- 683
		end -- 683
	end -- 683
end -- 683
function truncateText(text, maxLen) -- 929
	if #text <= maxLen then -- 929
		return text -- 930
	end -- 930
	local nextPos = utf8.offset(text, maxLen + 1) -- 931
	if nextPos == nil then -- 931
		return text -- 932
	end -- 932
	return string.sub(text, 1, nextPos - 1) .. "..." -- 933
end -- 933
function getReplyLanguageDirective(shared) -- 943
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 944
end -- 944
function replacePromptVars(template, vars) -- 949
	local output = template -- 950
	for key in pairs(vars) do -- 951
		output = table.concat( -- 952
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 952
			vars[key] or "" or "," -- 952
		) -- 952
	end -- 952
	return output -- 954
end -- 954
function getDecisionToolDefinitions(shared) -- 1078
	local base = replacePromptVars( -- 1079
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1080
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1081
	) -- 1081
	local spawnTool = "\n\n9. spawn_sub_agent: Create and start a sub agent session for implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this whenever the task requires direct coding, file editing, file deletion, build verification, documentation writing, or any other concrete execution work by a delegated sub agent.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- filesHint is an optional list of likely files or directories." -- 1083
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1092
		getAllowedToolsForRole(shared.role), -- 1093
		", " -- 1093
	) or "" -- 1093
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1095
	if (shared and shared.decisionMode) ~= "xml" then -- 1095
		return withRole -- 1097
	end -- 1097
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1099
end -- 1099
function persistHistoryState(shared) -- 1348
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 1349
end -- 1349
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 1431
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 1436
	if carryMessage then -- 1436
		__TS__ArrayUnshift( -- 1438
			remainingMessages, -- 1438
			__TS__ObjectAssign( -- 1438
				{}, -- 1438
				carryMessage, -- 1439
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1438
			) -- 1438
		) -- 1438
	end -- 1438
	shared.messages = remainingMessages -- 1443
end -- 1443
function getAllowedToolsForRole(role) -- 1720
	return role == "main" and ({ -- 1721
		"read_file", -- 1722
		"grep_files", -- 1722
		"search_dora_api", -- 1722
		"glob_files", -- 1722
		"spawn_sub_agent", -- 1722
		"finish" -- 1722
	}) or ({ -- 1722
		"read_file", -- 1723
		"edit_file", -- 1723
		"delete_file", -- 1723
		"grep_files", -- 1723
		"search_dora_api", -- 1723
		"glob_files", -- 1723
		"build", -- 1723
		"finish" -- 1723
	}) -- 1723
end -- 1723
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1819
	if includeToolDefinitions == nil then -- 1819
		includeToolDefinitions = false -- 1819
	end -- 1819
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase using search/discovery tools, and decide when to delegate implementation work by spawning sub agents.\n\nRules:\n- Do not perform direct code editing, deletion, or build actions yourself.\n- Use spawn_sub_agent when the task requires concrete implementation or verification work.\n- Code changes, file deletion, build/compile verification, and documentation writing should be delegated to a sub agent.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 1820
	local sections = { -- 1840
		shared.promptPack.agentIdentityPrompt, -- 1841
		rolePrompt, -- 1842
		getReplyLanguageDirective(shared) -- 1843
	} -- 1843
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1845
	if memoryContext ~= "" then -- 1845
		sections[#sections + 1] = memoryContext -- 1847
	end -- 1847
	if includeToolDefinitions then -- 1847
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1850
		if shared.decisionMode == "xml" then -- 1850
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1852
		end -- 1852
	end -- 1852
	local skillsSection = buildSkillsSection(shared) -- 1856
	if skillsSection ~= "" then -- 1856
		sections[#sections + 1] = skillsSection -- 1858
	end -- 1858
	return table.concat(sections, "\n\n") -- 1860
end -- 1860
function buildSkillsSection(shared) -- 1863
	local ____opt_32 = shared.skills -- 1863
	if not (____opt_32 and ____opt_32.loader) then -- 1863
		return "" -- 1865
	end -- 1865
	return shared.skills.loader:buildSkillsPromptSection() -- 1867
end -- 1867
function buildXmlDecisionInstruction(shared, feedback) -- 1979
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1980
end -- 1980
function emitAgentTaskFinishEvent(shared, success, message) -- 3015
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3016
	emitAgentEvent(shared, { -- 3022
		type = "task_finished", -- 3023
		sessionId = shared.sessionId, -- 3024
		taskId = shared.taskId, -- 3025
		success = result.success, -- 3026
		message = result.message, -- 3027
		steps = result.steps -- 3028
	}) -- 3028
	return result -- 3030
end -- 3030
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
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 501
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 624
local HISTORY_READ_FILE_MAX_LINES = 300 -- 625
local READ_FILE_DEFAULT_LIMIT = 300 -- 626
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 627
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 628
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 629
SEARCH_DORA_API_LIMIT_MAX = 20 -- 630
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 631
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 632
local SEARCH_PREVIEW_CONTEXT = 80 -- 633
local function emitAgentStartEvent(shared, action) -- 690
	emitAgentEvent(shared, { -- 691
		type = "tool_started", -- 692
		sessionId = shared.sessionId, -- 693
		taskId = shared.taskId, -- 694
		step = action.step, -- 695
		tool = action.tool -- 696
	}) -- 696
end -- 690
local function emitAgentFinishEvent(shared, action) -- 700
	emitAgentEvent(shared, { -- 701
		type = "tool_finished", -- 702
		sessionId = shared.sessionId, -- 703
		taskId = shared.taskId, -- 704
		step = action.step, -- 705
		tool = action.tool, -- 706
		result = action.result or ({}) -- 707
	}) -- 707
end -- 700
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 711
	emitAgentEvent(shared, { -- 712
		type = "assistant_message_updated", -- 713
		sessionId = shared.sessionId, -- 714
		taskId = shared.taskId, -- 715
		step = shared.step + 1, -- 716
		content = content, -- 717
		reasoningContent = reasoningContent -- 718
	}) -- 718
end -- 711
local function getMemoryCompressionStartReason(shared) -- 722
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 723
end -- 722
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 728
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 729
end -- 728
local function getMemoryCompressionFailureReason(shared, ____error) -- 734
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 735
end -- 734
local function summarizeHistoryEntryPreview(text, maxChars) -- 740
	if maxChars == nil then -- 740
		maxChars = 180 -- 740
	end -- 740
	local trimmed = __TS__StringTrim(text) -- 741
	if trimmed == "" then -- 741
		return "" -- 742
	end -- 742
	return truncateText(trimmed, maxChars) -- 743
end -- 740
local function getCancelledReason(shared) -- 746
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 746
		return shared.stopToken.reason -- 747
	end -- 747
	return shared.useChineseResponse and "已取消" or "cancelled" -- 748
end -- 746
local function getMaxStepsReachedReason(shared) -- 751
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 752
end -- 751
local function getFailureSummaryFallback(shared, ____error) -- 757
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 758
end -- 757
local function finalizeAgentFailure(shared, ____error) -- 763
	if shared.stopToken.stopped then -- 763
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 765
		return emitAgentTaskFinishEvent( -- 766
			shared, -- 766
			false, -- 766
			getCancelledReason(shared) -- 766
		) -- 766
	end -- 766
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 768
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 769
end -- 763
local function getPromptCommand(prompt) -- 772
	local trimmed = __TS__StringTrim(prompt) -- 773
	if trimmed == "/compact" then -- 773
		return "compact" -- 774
	end -- 774
	if trimmed == "/reset" then -- 774
		return "reset" -- 775
	end -- 775
	return nil -- 776
end -- 772
function ____exports.truncateAgentUserPrompt(prompt) -- 779
	if not prompt then -- 779
		return "" -- 780
	end -- 780
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 780
		return prompt -- 781
	end -- 781
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 782
	if offset == nil then -- 782
		return prompt -- 783
	end -- 783
	return string.sub(prompt, 1, offset - 1) -- 784
end -- 779
local function canWriteStepLLMDebug(shared, stepId) -- 787
	if stepId == nil then -- 787
		stepId = shared.step + 1 -- 787
	end -- 787
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 788
end -- 787
local function ensureDirRecursive(dir) -- 795
	if not dir then -- 795
		return false -- 796
	end -- 796
	if Content:exist(dir) then -- 796
		return Content:isdir(dir) -- 797
	end -- 797
	local parent = Path:getPath(dir) -- 798
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 798
		return false -- 800
	end -- 800
	return Content:mkdir(dir) -- 802
end -- 795
local function encodeDebugJSON(value) -- 805
	local text, err = safeJsonEncode(value) -- 806
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 807
end -- 805
local function getStepLLMDebugDir(shared) -- 810
	return Path( -- 811
		shared.workingDir, -- 812
		".agent", -- 813
		tostring(shared.sessionId), -- 814
		tostring(shared.taskId) -- 815
	) -- 815
end -- 810
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 819
	return Path( -- 820
		getStepLLMDebugDir(shared), -- 820
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 820
	) -- 820
end -- 819
local function getLatestStepLLMDebugSeq(shared, stepId) -- 823
	if not canWriteStepLLMDebug(shared, stepId) then -- 823
		return 0 -- 824
	end -- 824
	local dir = getStepLLMDebugDir(shared) -- 825
	if not Content:exist(dir) or not Content:isdir(dir) then -- 825
		return 0 -- 826
	end -- 826
	local latest = 0 -- 827
	for ____, file in ipairs(Content:getFiles(dir)) do -- 828
		do -- 828
			local name = Path:getFilename(file) -- 829
			local seqText = string.match( -- 830
				name, -- 830
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 830
			) -- 830
			if seqText ~= nil then -- 830
				latest = math.max( -- 832
					latest, -- 832
					tonumber(seqText) -- 832
				) -- 832
				goto __continue120 -- 833
			end -- 833
			local legacyMatch = string.match( -- 835
				name, -- 835
				("^" .. tostring(stepId)) .. "_in%.md$" -- 835
			) -- 835
			if legacyMatch ~= nil then -- 835
				latest = math.max(latest, 1) -- 837
			end -- 837
		end -- 837
		::__continue120:: -- 837
	end -- 837
	return latest -- 840
end -- 823
local function writeStepLLMDebugFile(path, content) -- 843
	if not Content:save(path, content) then -- 843
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 845
		return false -- 846
	end -- 846
	return true -- 848
end -- 843
local function createStepLLMDebugPair(shared, stepId, inContent) -- 851
	if not canWriteStepLLMDebug(shared, stepId) then -- 851
		return 0 -- 852
	end -- 852
	local dir = getStepLLMDebugDir(shared) -- 853
	if not ensureDirRecursive(dir) then -- 853
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 855
		return 0 -- 856
	end -- 856
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 858
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 859
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 860
	if not writeStepLLMDebugFile(inPath, inContent) then -- 860
		return 0 -- 862
	end -- 862
	writeStepLLMDebugFile(outPath, "") -- 864
	return seq -- 865
end -- 851
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 868
	if not canWriteStepLLMDebug(shared, stepId) then -- 868
		return -- 869
	end -- 869
	local dir = getStepLLMDebugDir(shared) -- 870
	if not ensureDirRecursive(dir) then -- 870
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 872
		return -- 873
	end -- 873
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 875
	if latestSeq <= 0 then -- 875
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 877
		writeStepLLMDebugFile(outPath, content) -- 878
		return -- 879
	end -- 879
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 881
	writeStepLLMDebugFile(outPath, content) -- 882
end -- 868
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 885
	if not canWriteStepLLMDebug(shared, stepId) then -- 885
		return -- 886
	end -- 886
	local sections = { -- 887
		"# LLM Input", -- 888
		"session_id: " .. tostring(shared.sessionId), -- 889
		"task_id: " .. tostring(shared.taskId), -- 890
		"step_id: " .. tostring(stepId), -- 891
		"phase: " .. phase, -- 892
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 893
		"## Options", -- 894
		"```json", -- 895
		encodeDebugJSON(options), -- 896
		"```" -- 897
	} -- 897
	do -- 897
		local i = 0 -- 899
		while i < #messages do -- 899
			local message = messages[i + 1] -- 900
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 901
			sections[#sections + 1] = encodeDebugJSON(message) -- 902
			i = i + 1 -- 899
		end -- 899
	end -- 899
	createStepLLMDebugPair( -- 904
		shared, -- 904
		stepId, -- 904
		table.concat(sections, "\n") -- 904
	) -- 904
end -- 885
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 907
	if not canWriteStepLLMDebug(shared, stepId) then -- 907
		return -- 908
	end -- 908
	local ____array_2 = __TS__SparseArrayNew( -- 908
		"# LLM Output", -- 910
		"session_id: " .. tostring(shared.sessionId), -- 911
		"task_id: " .. tostring(shared.taskId), -- 912
		"step_id: " .. tostring(stepId), -- 913
		"phase: " .. phase, -- 914
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 915
		table.unpack(meta and ({ -- 916
			"## Meta", -- 916
			"```json", -- 916
			encodeDebugJSON(meta), -- 916
			"```" -- 916
		}) or ({})) -- 916
	) -- 916
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 916
	local sections = {__TS__SparseArraySpread(____array_2)} -- 909
	updateLatestStepLLMDebugOutput( -- 920
		shared, -- 920
		stepId, -- 920
		table.concat(sections, "\n") -- 920
	) -- 920
end -- 907
local function toJson(value) -- 923
	local text, err = safeJsonEncode(value) -- 924
	if text ~= nil then -- 924
		return text -- 925
	end -- 925
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 926
end -- 923
local function utf8TakeHead(text, maxChars) -- 936
	if maxChars <= 0 or text == "" then -- 936
		return "" -- 937
	end -- 937
	local nextPos = utf8.offset(text, maxChars + 1) -- 938
	if nextPos == nil then -- 938
		return text -- 939
	end -- 939
	return string.sub(text, 1, nextPos - 1) -- 940
end -- 936
local function limitReadContentForHistory(content, tool) -- 957
	local lines = __TS__StringSplit(content, "\n") -- 958
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 959
	local limitedByLines = overLineLimit and table.concat( -- 960
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 961
		"\n" -- 961
	) or content -- 961
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 961
		return content -- 964
	end -- 964
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 966
	local reasons = {} -- 969
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 969
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 970
	end -- 970
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 970
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 971
	end -- 971
	local hint = "Narrow the requested line range." -- 972
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 973
end -- 957
local function summarizeEditTextParamForHistory(value, key) -- 976
	if type(value) ~= "string" then -- 976
		return nil -- 977
	end -- 977
	local text = value -- 978
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 979
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 980
end -- 976
local function sanitizeReadResultForHistory(tool, result) -- 988
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 988
		return result -- 990
	end -- 990
	local clone = {} -- 992
	for key in pairs(result) do -- 993
		clone[key] = result[key] -- 994
	end -- 994
	clone.content = limitReadContentForHistory(result.content, tool) -- 996
	return clone -- 997
end -- 988
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1000
	local shown = math.min(#items, maxItems) -- 1004
	local out = {} -- 1005
	do -- 1005
		local i = 0 -- 1006
		while i < shown do -- 1006
			local row = items[i + 1] -- 1007
			out[#out + 1] = { -- 1008
				file = row.file, -- 1009
				line = row.line, -- 1010
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1011
			} -- 1011
			i = i + 1 -- 1006
		end -- 1006
	end -- 1006
	return out -- 1016
end -- 1000
local function sanitizeSearchResultForHistory(tool, result) -- 1019
	if result.success ~= true or not isArray(result.results) then -- 1019
		return result -- 1023
	end -- 1023
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1023
		return result -- 1024
	end -- 1024
	local clone = {} -- 1025
	for key in pairs(result) do -- 1026
		clone[key] = result[key] -- 1027
	end -- 1027
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1029
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1030
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1030
		local grouped = result.groupedResults -- 1035
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1036
		local sanitizedGroups = {} -- 1037
		do -- 1037
			local i = 0 -- 1038
			while i < shown do -- 1038
				local row = grouped[i + 1] -- 1039
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1040
					file = row.file, -- 1041
					totalMatches = row.totalMatches, -- 1042
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1043
				} -- 1043
				i = i + 1 -- 1038
			end -- 1038
		end -- 1038
		clone.groupedResults = sanitizedGroups -- 1048
	end -- 1048
	return clone -- 1050
end -- 1019
local function sanitizeListFilesResultForHistory(result) -- 1053
	if result.success ~= true or not isArray(result.files) then -- 1053
		return result -- 1054
	end -- 1054
	local clone = {} -- 1055
	for key in pairs(result) do -- 1056
		clone[key] = result[key] -- 1057
	end -- 1057
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1059
	return clone -- 1060
end -- 1053
local function sanitizeActionParamsForHistory(tool, params) -- 1063
	if tool ~= "edit_file" then -- 1063
		return params -- 1064
	end -- 1064
	local clone = {} -- 1065
	for key in pairs(params) do -- 1066
		if key == "old_str" then -- 1066
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1068
		elseif key == "new_str" then -- 1068
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1070
		else -- 1070
			clone[key] = params[key] -- 1072
		end -- 1072
	end -- 1072
	return clone -- 1075
end -- 1063
local function isToolAllowedForRole(role, tool) -- 1108
	return __TS__ArrayIndexOf( -- 1109
		getAllowedToolsForRole(role), -- 1109
		tool -- 1109
	) >= 0 -- 1109
end -- 1108
local function maybeCompressHistory(shared) -- 1112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1112
		local ____shared_9 = shared -- 1113
		local memory = ____shared_9.memory -- 1113
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1114
		local changed = false -- 1115
		do -- 1115
			local round = 0 -- 1116
			while round < maxRounds do -- 1116
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1117
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1121
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 1121
					if changed then -- 1121
						persistHistoryState(shared) -- 1130
					end -- 1130
					return ____awaiter_resolve(nil) -- 1130
				end -- 1130
				local compressionRound = round + 1 -- 1134
				shared.step = shared.step + 1 -- 1135
				local stepId = shared.step -- 1136
				local pendingMessages = #shared.messages -- 1137
				emitAgentEvent( -- 1138
					shared, -- 1138
					{ -- 1138
						type = "memory_compression_started", -- 1139
						sessionId = shared.sessionId, -- 1140
						taskId = shared.taskId, -- 1141
						step = stepId, -- 1142
						tool = "compress_memory", -- 1143
						reason = getMemoryCompressionStartReason(shared), -- 1144
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1145
					} -- 1145
				) -- 1145
				local result = __TS__Await(memory.compressor:compress( -- 1151
					shared.messages, -- 1152
					shared.llmOptions, -- 1153
					shared.llmMaxTry, -- 1154
					shared.decisionMode, -- 1155
					{ -- 1156
						onInput = function(____, phase, messages, options) -- 1157
							saveStepLLMDebugInput( -- 1158
								shared, -- 1158
								stepId, -- 1158
								phase, -- 1158
								messages, -- 1158
								options -- 1158
							) -- 1158
						end, -- 1157
						onOutput = function(____, phase, text, meta) -- 1160
							saveStepLLMDebugOutput( -- 1161
								shared, -- 1161
								stepId, -- 1161
								phase, -- 1161
								text, -- 1161
								meta -- 1161
							) -- 1161
						end -- 1160
					}, -- 1160
					"default", -- 1164
					systemPrompt, -- 1165
					toolDefinitions -- 1166
				)) -- 1166
				if not (result and result.success and result.compressedCount > 0) then -- 1166
					emitAgentEvent( -- 1169
						shared, -- 1169
						{ -- 1169
							type = "memory_compression_finished", -- 1170
							sessionId = shared.sessionId, -- 1171
							taskId = shared.taskId, -- 1172
							step = stepId, -- 1173
							tool = "compress_memory", -- 1174
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1175
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1179
						} -- 1179
					) -- 1179
					if changed then -- 1179
						persistHistoryState(shared) -- 1187
					end -- 1187
					return ____awaiter_resolve(nil) -- 1187
				end -- 1187
				emitAgentEvent( -- 1191
					shared, -- 1191
					{ -- 1191
						type = "memory_compression_finished", -- 1192
						sessionId = shared.sessionId, -- 1193
						taskId = shared.taskId, -- 1194
						step = stepId, -- 1195
						tool = "compress_memory", -- 1196
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1197
						result = { -- 1198
							success = true, -- 1199
							round = compressionRound, -- 1200
							compressedCount = result.compressedCount, -- 1201
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1202
						} -- 1202
					} -- 1202
				) -- 1202
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1205
				changed = true -- 1206
				Log( -- 1207
					"Info", -- 1207
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1207
				) -- 1207
				round = round + 1 -- 1116
			end -- 1116
		end -- 1116
		if changed then -- 1116
			persistHistoryState(shared) -- 1210
		end -- 1210
	end) -- 1210
end -- 1112
local function compactAllHistory(shared) -- 1214
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1214
		local ____shared_16 = shared -- 1215
		local memory = ____shared_16.memory -- 1215
		local rounds = 0 -- 1216
		local totalCompressed = 0 -- 1217
		while #shared.messages > 0 do -- 1217
			if shared.stopToken.stopped then -- 1217
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1220
				return ____awaiter_resolve( -- 1220
					nil, -- 1220
					emitAgentTaskFinishEvent( -- 1221
						shared, -- 1221
						false, -- 1221
						getCancelledReason(shared) -- 1221
					) -- 1221
				) -- 1221
			end -- 1221
			rounds = rounds + 1 -- 1223
			shared.step = shared.step + 1 -- 1224
			local stepId = shared.step -- 1225
			local pendingMessages = #shared.messages -- 1226
			emitAgentEvent( -- 1227
				shared, -- 1227
				{ -- 1227
					type = "memory_compression_started", -- 1228
					sessionId = shared.sessionId, -- 1229
					taskId = shared.taskId, -- 1230
					step = stepId, -- 1231
					tool = "compress_memory", -- 1232
					reason = getMemoryCompressionStartReason(shared), -- 1233
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1234
				} -- 1234
			) -- 1234
			local result = __TS__Await(memory.compressor:compress( -- 1241
				shared.messages, -- 1242
				shared.llmOptions, -- 1243
				shared.llmMaxTry, -- 1244
				shared.decisionMode, -- 1245
				{ -- 1246
					onInput = function(____, phase, messages, options) -- 1247
						saveStepLLMDebugInput( -- 1248
							shared, -- 1248
							stepId, -- 1248
							phase, -- 1248
							messages, -- 1248
							options -- 1248
						) -- 1248
					end, -- 1247
					onOutput = function(____, phase, text, meta) -- 1250
						saveStepLLMDebugOutput( -- 1251
							shared, -- 1251
							stepId, -- 1251
							phase, -- 1251
							text, -- 1251
							meta -- 1251
						) -- 1251
					end -- 1250
				}, -- 1250
				"budget_max" -- 1254
			)) -- 1254
			if not (result and result.success and result.compressedCount > 0) then -- 1254
				emitAgentEvent( -- 1257
					shared, -- 1257
					{ -- 1257
						type = "memory_compression_finished", -- 1258
						sessionId = shared.sessionId, -- 1259
						taskId = shared.taskId, -- 1260
						step = stepId, -- 1261
						tool = "compress_memory", -- 1262
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1263
						result = { -- 1267
							success = false, -- 1268
							rounds = rounds, -- 1269
							error = result and result.error or "compression returned no changes", -- 1270
							compressedCount = result and result.compressedCount or 0, -- 1271
							fullCompaction = true -- 1272
						} -- 1272
					} -- 1272
				) -- 1272
				return ____awaiter_resolve( -- 1272
					nil, -- 1272
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1275
				) -- 1275
			end -- 1275
			emitAgentEvent( -- 1280
				shared, -- 1280
				{ -- 1280
					type = "memory_compression_finished", -- 1281
					sessionId = shared.sessionId, -- 1282
					taskId = shared.taskId, -- 1283
					step = stepId, -- 1284
					tool = "compress_memory", -- 1285
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1286
					result = { -- 1287
						success = true, -- 1288
						round = rounds, -- 1289
						compressedCount = result.compressedCount, -- 1290
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1291
						fullCompaction = true -- 1292
					} -- 1292
				} -- 1292
			) -- 1292
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1295
			totalCompressed = totalCompressed + result.compressedCount -- 1296
			persistHistoryState(shared) -- 1297
			Log( -- 1298
				"Info", -- 1298
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1298
			) -- 1298
		end -- 1298
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1300
		return ____awaiter_resolve( -- 1300
			nil, -- 1300
			emitAgentTaskFinishEvent( -- 1301
				shared, -- 1302
				true, -- 1303
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1304
			) -- 1304
		) -- 1304
	end) -- 1304
end -- 1214
local function resetSessionHistory(shared) -- 1310
	shared.messages = {} -- 1311
	persistHistoryState(shared) -- 1312
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1313
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1314
end -- 1310
local function isKnownToolName(name) -- 1323
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "spawn_sub_agent" or name == "finish" -- 1324
end -- 1323
local function getFinishMessage(params, fallback) -- 1335
	if fallback == nil then -- 1335
		fallback = "" -- 1335
	end -- 1335
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1335
		return __TS__StringTrim(params.message) -- 1337
	end -- 1337
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1337
		return __TS__StringTrim(params.response) -- 1340
	end -- 1340
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1340
		return __TS__StringTrim(params.summary) -- 1343
	end -- 1343
	return __TS__StringTrim(fallback) -- 1345
end -- 1335
local function maybeProcessPendingMemoryMerge(shared) -- 1352
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1352
		if shared.role ~= "main" then -- 1352
			return ____awaiter_resolve(nil) -- 1352
		end -- 1352
		local queue = shared.memory.compressor:getMergeQueue() -- 1356
		while true do -- 1356
			do -- 1356
				local job = queue:readOldestJob() -- 1358
				if not job then -- 1358
					return ____awaiter_resolve(nil) -- 1358
				end -- 1358
				shared.step = shared.step + 1 -- 1362
				local stepId = shared.step -- 1363
				emitAgentEvent(shared, { -- 1364
					type = "memory_merge_started", -- 1365
					sessionId = shared.sessionId, -- 1366
					taskId = shared.taskId, -- 1367
					step = stepId, -- 1368
					jobId = job.jobId, -- 1369
					sourceAgentId = job.sourceAgentId, -- 1370
					sourceTitle = job.sourceTitle -- 1371
				}) -- 1371
				Log("Info", (("[CodingAgent] processing memory merge job=" .. job.jobId) .. " source=") .. job.sourceAgentId) -- 1373
				local result = __TS__Await(shared.memory.compressor:mergeSubAgentMemory( -- 1374
					job, -- 1375
					shared.llmOptions, -- 1376
					shared.llmMaxTry, -- 1377
					shared.decisionMode, -- 1378
					{ -- 1379
						onInput = function(____, phase, messages, options) -- 1380
							saveStepLLMDebugInput( -- 1381
								shared, -- 1381
								stepId, -- 1381
								phase .. "_merge", -- 1381
								messages, -- 1381
								options -- 1381
							) -- 1381
						end, -- 1380
						onOutput = function(____, phase, text, meta) -- 1383
							saveStepLLMDebugOutput( -- 1384
								shared, -- 1384
								stepId, -- 1384
								phase .. "_merge", -- 1384
								text, -- 1384
								meta -- 1384
							) -- 1384
						end -- 1383
					} -- 1383
				)) -- 1383
				if result.success then -- 1383
					queue:deleteJob(job.path) -- 1389
					emitAgentEvent(shared, { -- 1390
						type = "memory_merge_finished", -- 1391
						sessionId = shared.sessionId, -- 1392
						taskId = shared.taskId, -- 1393
						step = stepId, -- 1394
						jobId = job.jobId, -- 1395
						sourceAgentId = job.sourceAgentId, -- 1396
						sourceTitle = job.sourceTitle, -- 1397
						success = true, -- 1398
						message = shared.useChineseResponse and ("已合并来自`" .. job.sourceTitle) .. "`的子代理记忆。" or ("Merged sub-agent memory from `" .. job.sourceTitle) .. "`.", -- 1399
						attempts = job.attempts -- 1402
					}) -- 1402
					Log("Info", "[CodingAgent] memory merge job applied=" .. job.jobId) -- 1404
					goto __continue212 -- 1405
				end -- 1405
				queue:updateJobFailure(job, result.error or "memory merge failed") -- 1407
				local nextAttempts = (job.attempts or 0) + 1 -- 1408
				emitAgentEvent(shared, { -- 1409
					type = "memory_merge_finished", -- 1410
					sessionId = shared.sessionId, -- 1411
					taskId = shared.taskId, -- 1412
					step = stepId, -- 1413
					jobId = job.jobId, -- 1414
					sourceAgentId = job.sourceAgentId, -- 1415
					sourceTitle = job.sourceTitle, -- 1416
					success = false, -- 1417
					message = result.error or "memory merge failed", -- 1418
					attempts = nextAttempts -- 1419
				}) -- 1419
				Log("Warn", (("[CodingAgent] memory merge job failed=" .. job.jobId) .. " error=") .. (result.error or "unknown")) -- 1421
				if nextAttempts >= shared.llmMaxTry then -- 1421
					error( -- 1423
						__TS__New(Error, shared.useChineseResponse and (("记忆合并任务多次失败，已中止当前会话。来源：" .. job.sourceTitle) .. "，错误：") .. (result.error or "unknown") or (("Memory merge job exceeded retry limit and aborted the current session. Source: " .. job.sourceTitle) .. ". Error: ") .. (result.error or "unknown")), -- 1423
						0 -- 1423
					) -- 1423
				end -- 1423
				goto __continue212 -- 1427
			end -- 1427
			::__continue212:: -- 1427
		end -- 1427
	end) -- 1427
end -- 1352
local function appendConversationMessage(shared, message) -- 1446
	local ____shared_messages_25 = shared.messages -- 1446
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1447
		{}, -- 1447
		message, -- 1448
		{ -- 1447
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1449
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1450
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1451
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1452
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1453
		} -- 1453
	) -- 1453
end -- 1446
local function ensureToolCallId(toolCallId) -- 1457
	if toolCallId and toolCallId ~= "" then -- 1457
		return toolCallId -- 1458
	end -- 1458
	return createLocalToolCallId() -- 1459
end -- 1457
local function appendToolResultMessage(shared, action) -- 1462
	appendConversationMessage( -- 1463
		shared, -- 1463
		{ -- 1463
			role = "tool", -- 1464
			tool_call_id = action.toolCallId, -- 1465
			name = action.tool, -- 1466
			content = action.result and toJson(action.result) or "" -- 1467
		} -- 1467
	) -- 1467
end -- 1462
local function parseXMLToolCallObjectFromText(text) -- 1471
	local children = parseXMLObjectFromText(text, "tool_call") -- 1472
	if not children.success then -- 1472
		return children -- 1473
	end -- 1473
	local rawObj = children.obj -- 1474
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1475
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1476
	if not params.success then -- 1476
		return {success = false, message = params.message} -- 1480
	end -- 1480
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1482
end -- 1471
local function llm(shared, messages, phase) -- 1501
	if phase == nil then -- 1501
		phase = "decision_xml" -- 1504
	end -- 1504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1504
		local stepId = shared.step + 1 -- 1506
		saveStepLLMDebugInput( -- 1507
			shared, -- 1507
			stepId, -- 1507
			phase, -- 1507
			messages, -- 1507
			shared.llmOptions -- 1507
		) -- 1507
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1508
		if res.success then -- 1508
			local ____opt_30 = res.response.choices -- 1508
			local ____opt_28 = ____opt_30 and ____opt_30[1] -- 1508
			local ____opt_26 = ____opt_28 and ____opt_28.message -- 1508
			local text = ____opt_26 and ____opt_26.content -- 1510
			if text then -- 1510
				saveStepLLMDebugOutput( -- 1512
					shared, -- 1512
					stepId, -- 1512
					phase, -- 1512
					text, -- 1512
					{success = true} -- 1512
				) -- 1512
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 1512
			else -- 1512
				saveStepLLMDebugOutput( -- 1515
					shared, -- 1515
					stepId, -- 1515
					phase, -- 1515
					"empty LLM response", -- 1515
					{success = false} -- 1515
				) -- 1515
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1515
			end -- 1515
		else -- 1515
			saveStepLLMDebugOutput( -- 1519
				shared, -- 1519
				stepId, -- 1519
				phase, -- 1519
				res.raw or res.message, -- 1519
				{success = false} -- 1519
			) -- 1519
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1519
		end -- 1519
	end) -- 1519
end -- 1501
local function parseDecisionObject(rawObj) -- 1536
	if type(rawObj.tool) ~= "string" then -- 1536
		return {success = false, message = "missing tool"} -- 1537
	end -- 1537
	local tool = rawObj.tool -- 1538
	if not isKnownToolName(tool) then -- 1538
		return {success = false, message = "unknown tool: " .. tool} -- 1540
	end -- 1540
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1542
	if tool ~= "finish" and (not reason or reason == "") then -- 1542
		return {success = false, message = tool .. " requires top-level reason"} -- 1546
	end -- 1546
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1548
	return {success = true, tool = tool, params = params, reason = reason} -- 1549
end -- 1536
local function parseDecisionToolCall(functionName, rawObj) -- 1557
	if not isKnownToolName(functionName) then -- 1557
		return {success = false, message = "unknown tool: " .. functionName} -- 1559
	end -- 1559
	if rawObj == nil or rawObj == nil then -- 1559
		return {success = true, tool = functionName, params = {}} -- 1562
	end -- 1562
	if not isRecord(rawObj) then -- 1562
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1565
	end -- 1565
	return {success = true, tool = functionName, params = rawObj} -- 1567
end -- 1557
local function getDecisionPath(params) -- 1574
	if type(params.path) == "string" then -- 1574
		return __TS__StringTrim(params.path) -- 1575
	end -- 1575
	if type(params.target_file) == "string" then -- 1575
		return __TS__StringTrim(params.target_file) -- 1576
	end -- 1576
	return "" -- 1577
end -- 1574
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1580
	local num = __TS__Number(value) -- 1581
	if not __TS__NumberIsFinite(num) then -- 1581
		num = fallback -- 1582
	end -- 1582
	num = math.floor(num) -- 1583
	if num < minValue then -- 1583
		num = minValue -- 1584
	end -- 1584
	if maxValue ~= nil and num > maxValue then -- 1584
		num = maxValue -- 1585
	end -- 1585
	return num -- 1586
end -- 1580
local function parseReadLineParam(value, fallback, paramName) -- 1589
	local num = __TS__Number(value) -- 1594
	if not __TS__NumberIsFinite(num) then -- 1594
		num = fallback -- 1595
	end -- 1595
	num = math.floor(num) -- 1596
	if num == 0 then -- 1596
		return {success = false, message = paramName .. " cannot be 0"} -- 1598
	end -- 1598
	return {success = true, value = num} -- 1600
end -- 1589
local function validateDecision(tool, params) -- 1603
	if tool == "finish" then -- 1603
		local message = getFinishMessage(params) -- 1608
		if message == "" then -- 1608
			return {success = false, message = "finish requires params.message"} -- 1609
		end -- 1609
		params.message = message -- 1610
		return {success = true, params = params} -- 1611
	end -- 1611
	if tool == "read_file" then -- 1611
		local path = getDecisionPath(params) -- 1615
		if path == "" then -- 1615
			return {success = false, message = "read_file requires path"} -- 1616
		end -- 1616
		params.path = path -- 1617
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1618
		if not startLineRes.success then -- 1618
			return startLineRes -- 1619
		end -- 1619
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1620
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1621
		if not endLineRes.success then -- 1621
			return endLineRes -- 1622
		end -- 1622
		params.startLine = startLineRes.value -- 1623
		params.endLine = endLineRes.value -- 1624
		return {success = true, params = params} -- 1625
	end -- 1625
	if tool == "edit_file" then -- 1625
		local path = getDecisionPath(params) -- 1629
		if path == "" then -- 1629
			return {success = false, message = "edit_file requires path"} -- 1630
		end -- 1630
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1631
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1632
		params.path = path -- 1633
		params.old_str = oldStr -- 1634
		params.new_str = newStr -- 1635
		return {success = true, params = params} -- 1636
	end -- 1636
	if tool == "delete_file" then -- 1636
		local targetFile = getDecisionPath(params) -- 1640
		if targetFile == "" then -- 1640
			return {success = false, message = "delete_file requires target_file"} -- 1641
		end -- 1641
		params.target_file = targetFile -- 1642
		return {success = true, params = params} -- 1643
	end -- 1643
	if tool == "grep_files" then -- 1643
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1647
		if pattern == "" then -- 1647
			return {success = false, message = "grep_files requires pattern"} -- 1648
		end -- 1648
		params.pattern = pattern -- 1649
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1650
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1651
		return {success = true, params = params} -- 1652
	end -- 1652
	if tool == "search_dora_api" then -- 1652
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1656
		if pattern == "" then -- 1656
			return {success = false, message = "search_dora_api requires pattern"} -- 1657
		end -- 1657
		params.pattern = pattern -- 1658
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1659
		return {success = true, params = params} -- 1660
	end -- 1660
	if tool == "glob_files" then -- 1660
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1664
		return {success = true, params = params} -- 1665
	end -- 1665
	if tool == "build" then -- 1665
		local path = getDecisionPath(params) -- 1669
		if path ~= "" then -- 1669
			params.path = path -- 1671
		end -- 1671
		return {success = true, params = params} -- 1673
	end -- 1673
	if tool == "spawn_sub_agent" then -- 1673
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1677
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1678
		if prompt == "" then -- 1678
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1679
		end -- 1679
		if title == "" then -- 1679
			return {success = false, message = "spawn_sub_agent requires title"} -- 1680
		end -- 1680
		params.prompt = prompt -- 1681
		params.title = title -- 1682
		if type(params.expectedOutput) == "string" then -- 1682
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1684
		end -- 1684
		if isArray(params.filesHint) then -- 1684
			params.filesHint = __TS__ArrayMap( -- 1687
				__TS__ArrayFilter( -- 1687
					params.filesHint, -- 1687
					function(____, item) return type(item) == "string" end -- 1688
				), -- 1688
				function(____, item) return sanitizeUTF8(item) end -- 1689
			) -- 1689
		end -- 1689
		return {success = true, params = params} -- 1691
	end -- 1691
	return {success = true, params = params} -- 1694
end -- 1603
local function createFunctionToolSchema(name, description, properties, required) -- 1697
	if required == nil then -- 1697
		required = {} -- 1701
	end -- 1701
	local parameters = {type = "object", properties = properties} -- 1703
	if #required > 0 then -- 1703
		parameters.required = required -- 1708
	end -- 1708
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1710
end -- 1697
local function buildDecisionToolSchema(shared) -- 1726
	local allowed = getAllowedToolsForRole(shared.role) -- 1727
	local tools = { -- 1728
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1729
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1739
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1749
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1757
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1761
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1762
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1763
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1764
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1765
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1766
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1767
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1768
		}, {"pattern"}), -- 1768
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1772
		createFunctionToolSchema( -- 1781
			"search_dora_api", -- 1782
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1782
			{ -- 1784
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1785
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1786
				programmingLanguage = {type = "string", enum = { -- 1787
					"ts", -- 1789
					"tsx", -- 1789
					"lua", -- 1789
					"yue", -- 1789
					"teal", -- 1789
					"tl", -- 1789
					"wa" -- 1789
				}, description = "Preferred language variant to search."}, -- 1789
				limit = { -- 1792
					type = "number", -- 1792
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1792
				}, -- 1792
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1793
			}, -- 1793
			{"pattern"} -- 1795
		), -- 1795
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1797
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute concrete work. Use this when the task moves from discussion/search into coding, file editing, file deletion, build verification, documentation writing, or other execution-heavy work. The sub agent has the full execution toolset including edit_file, delete_file, and build.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1804
	} -- 1804
	return __TS__ArrayFilter( -- 1816
		tools, -- 1816
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1816
	) -- 1816
end -- 1726
local function sanitizeMessagesForLLMInput(messages) -- 1870
	local sanitized = {} -- 1871
	local droppedAssistantToolCalls = 0 -- 1872
	local droppedToolResults = 0 -- 1873
	do -- 1873
		local i = 0 -- 1874
		while i < #messages do -- 1874
			do -- 1874
				local message = messages[i + 1] -- 1875
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1875
					local requiredIds = {} -- 1877
					do -- 1877
						local j = 0 -- 1878
						while j < #message.tool_calls do -- 1878
							local toolCall = message.tool_calls[j + 1] -- 1879
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1880
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1880
								requiredIds[#requiredIds + 1] = id -- 1882
							end -- 1882
							j = j + 1 -- 1878
						end -- 1878
					end -- 1878
					if #requiredIds == 0 then -- 1878
						sanitized[#sanitized + 1] = message -- 1886
						goto __continue289 -- 1887
					end -- 1887
					local matchedIds = {} -- 1889
					local matchedTools = {} -- 1890
					local j = i + 1 -- 1891
					while j < #messages do -- 1891
						local toolMessage = messages[j + 1] -- 1893
						if toolMessage.role ~= "tool" then -- 1893
							break -- 1894
						end -- 1894
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1895
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1895
							matchedIds[toolCallId] = true -- 1897
							matchedTools[#matchedTools + 1] = toolMessage -- 1898
						else -- 1898
							droppedToolResults = droppedToolResults + 1 -- 1900
						end -- 1900
						j = j + 1 -- 1902
					end -- 1902
					local complete = true -- 1904
					do -- 1904
						local j = 0 -- 1905
						while j < #requiredIds do -- 1905
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1905
								complete = false -- 1907
								break -- 1908
							end -- 1908
							j = j + 1 -- 1905
						end -- 1905
					end -- 1905
					if complete then -- 1905
						__TS__ArrayPush( -- 1912
							sanitized, -- 1912
							message, -- 1912
							table.unpack(matchedTools) -- 1912
						) -- 1912
					else -- 1912
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1914
						droppedToolResults = droppedToolResults + #matchedTools -- 1915
					end -- 1915
					i = j - 1 -- 1917
					goto __continue289 -- 1918
				end -- 1918
				if message.role == "tool" then -- 1918
					droppedToolResults = droppedToolResults + 1 -- 1921
					goto __continue289 -- 1922
				end -- 1922
				sanitized[#sanitized + 1] = message -- 1924
			end -- 1924
			::__continue289:: -- 1924
			i = i + 1 -- 1874
		end -- 1874
	end -- 1874
	return sanitized -- 1926
end -- 1870
local function getUnconsolidatedMessages(shared) -- 1929
	return sanitizeMessagesForLLMInput(shared.messages) -- 1930
end -- 1929
local function getFinalDecisionTurnPrompt(shared) -- 1933
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1934
end -- 1933
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1939
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1939
		return messages -- 1940
	end -- 1940
	local next = __TS__ArrayMap( -- 1941
		messages, -- 1941
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1941
	) -- 1941
	do -- 1941
		local i = #next - 1 -- 1942
		while i >= 0 do -- 1942
			do -- 1942
				local message = next[i + 1] -- 1943
				if message.role ~= "assistant" and message.role ~= "user" then -- 1943
					goto __continue311 -- 1944
				end -- 1944
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1945
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1946
				return next -- 1949
			end -- 1949
			::__continue311:: -- 1949
			i = i - 1 -- 1942
		end -- 1942
	end -- 1942
	next[#next + 1] = {role = "user", content = prompt} -- 1951
	return next -- 1952
end -- 1939
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1955
	if attempt == nil then -- 1955
		attempt = 1 -- 1955
	end -- 1955
	local messages = { -- 1956
		{ -- 1957
			role = "system", -- 1957
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1957
		}, -- 1957
		table.unpack(getUnconsolidatedMessages(shared)) -- 1958
	} -- 1958
	if shared.step + 1 >= shared.maxSteps then -- 1958
		messages = appendPromptToLatestDecisionMessage( -- 1961
			messages, -- 1961
			getFinalDecisionTurnPrompt(shared) -- 1961
		) -- 1961
	end -- 1961
	if lastError and lastError ~= "" then -- 1961
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1964
		messages[#messages + 1] = { -- 1967
			role = "user", -- 1968
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1969
		} -- 1969
	end -- 1969
	return messages -- 1976
end -- 1955
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1983
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1990
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1991
	local repairPrompt = replacePromptVars( -- 1999
		shared.promptPack.xmlDecisionRepairPrompt, -- 1999
		{ -- 1999
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2000
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2001
			CANDIDATE_SECTION = candidateSection, -- 2002
			LAST_ERROR = lastError, -- 2003
			ATTEMPT = tostring(attempt) -- 2004
		} -- 2004
	) -- 2004
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2006
end -- 1983
local function tryParseAndValidateDecision(rawText) -- 2018
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2019
	if not parsed.success then -- 2019
		return {success = false, message = parsed.message, raw = rawText} -- 2021
	end -- 2021
	local decision = parseDecisionObject(parsed.obj) -- 2023
	if not decision.success then -- 2023
		return {success = false, message = decision.message, raw = rawText} -- 2025
	end -- 2025
	local validation = validateDecision(decision.tool, decision.params) -- 2027
	if not validation.success then -- 2027
		return {success = false, message = validation.message, raw = rawText} -- 2029
	end -- 2029
	decision.params = validation.params -- 2031
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2032
	return decision -- 2033
end -- 2018
local function normalizeLineEndings(text) -- 2036
	local res = string.gsub(text, "\r\n", "\n") -- 2037
	res = string.gsub(res, "\r", "\n") -- 2038
	return res -- 2039
end -- 2036
local function countOccurrences(text, searchStr) -- 2042
	if searchStr == "" then -- 2042
		return 0 -- 2043
	end -- 2043
	local count = 0 -- 2044
	local pos = 0 -- 2045
	while true do -- 2045
		local idx = (string.find( -- 2047
			text, -- 2047
			searchStr, -- 2047
			math.max(pos + 1, 1), -- 2047
			true -- 2047
		) or 0) - 1 -- 2047
		if idx < 0 then -- 2047
			break -- 2048
		end -- 2048
		count = count + 1 -- 2049
		pos = idx + #searchStr -- 2050
	end -- 2050
	return count -- 2052
end -- 2042
local function replaceFirst(text, oldStr, newStr) -- 2055
	if oldStr == "" then -- 2055
		return text -- 2056
	end -- 2056
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2057
	if idx < 0 then -- 2057
		return text -- 2058
	end -- 2058
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2059
end -- 2055
local function splitLines(text) -- 2062
	return __TS__StringSplit(text, "\n") -- 2063
end -- 2062
local function getLeadingWhitespace(text) -- 2066
	local i = 0 -- 2067
	while i < #text do -- 2067
		local ch = __TS__StringAccess(text, i) -- 2069
		if ch ~= " " and ch ~= "\t" then -- 2069
			break -- 2070
		end -- 2070
		i = i + 1 -- 2071
	end -- 2071
	return __TS__StringSubstring(text, 0, i) -- 2073
end -- 2066
local function getCommonIndentPrefix(lines) -- 2076
	local common -- 2077
	do -- 2077
		local i = 0 -- 2078
		while i < #lines do -- 2078
			do -- 2078
				local line = lines[i + 1] -- 2079
				if __TS__StringTrim(line) == "" then -- 2079
					goto __continue336 -- 2080
				end -- 2080
				local indent = getLeadingWhitespace(line) -- 2081
				if common == nil then -- 2081
					common = indent -- 2083
					goto __continue336 -- 2084
				end -- 2084
				local j = 0 -- 2086
				local maxLen = math.min(#common, #indent) -- 2087
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2087
					j = j + 1 -- 2089
				end -- 2089
				common = __TS__StringSubstring(common, 0, j) -- 2091
				if common == "" then -- 2091
					break -- 2092
				end -- 2092
			end -- 2092
			::__continue336:: -- 2092
			i = i + 1 -- 2078
		end -- 2078
	end -- 2078
	return common or "" -- 2094
end -- 2076
local function removeIndentPrefix(line, indent) -- 2097
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2097
		return __TS__StringSubstring(line, #indent) -- 2099
	end -- 2099
	local lineIndent = getLeadingWhitespace(line) -- 2101
	local j = 0 -- 2102
	local maxLen = math.min(#lineIndent, #indent) -- 2103
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2103
		j = j + 1 -- 2105
	end -- 2105
	return __TS__StringSubstring(line, j) -- 2107
end -- 2097
local function dedentLines(lines) -- 2110
	local indent = getCommonIndentPrefix(lines) -- 2111
	return { -- 2112
		indent = indent, -- 2113
		lines = __TS__ArrayMap( -- 2114
			lines, -- 2114
			function(____, line) return removeIndentPrefix(line, indent) end -- 2114
		) -- 2114
	} -- 2114
end -- 2110
local function joinLines(lines) -- 2118
	return table.concat(lines, "\n") -- 2119
end -- 2118
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2122
	local contentLines = splitLines(content) -- 2127
	local oldLines = splitLines(oldStr) -- 2128
	if #oldLines == 0 then -- 2128
		return {success = false, message = "old_str not found in file"} -- 2130
	end -- 2130
	local dedentedOld = dedentLines(oldLines) -- 2132
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2133
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2134
	local matches = {} -- 2135
	do -- 2135
		local start = 0 -- 2136
		while start <= #contentLines - #oldLines do -- 2136
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2137
			local dedentedCandidate = dedentLines(candidateLines) -- 2138
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2138
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2140
			end -- 2140
			start = start + 1 -- 2136
		end -- 2136
	end -- 2136
	if #matches == 0 then -- 2136
		return {success = false, message = "old_str not found in file"} -- 2148
	end -- 2148
	if #matches > 1 then -- 2148
		return { -- 2151
			success = false, -- 2152
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2153
		} -- 2153
	end -- 2153
	local match = matches[1] -- 2156
	local rebuiltNewLines = __TS__ArrayMap( -- 2157
		dedentedNew.lines, -- 2157
		function(____, line) return line == "" and "" or match.indent .. line end -- 2157
	) -- 2157
	local ____array_36 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2157
	__TS__SparseArrayPush( -- 2157
		____array_36, -- 2157
		table.unpack(rebuiltNewLines) -- 2160
	) -- 2160
	__TS__SparseArrayPush( -- 2160
		____array_36, -- 2160
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2161
	) -- 2161
	local nextLines = {__TS__SparseArraySpread(____array_36)} -- 2158
	return { -- 2163
		success = true, -- 2163
		content = joinLines(nextLines) -- 2163
	} -- 2163
end -- 2122
local MainDecisionAgent = __TS__Class() -- 2166
MainDecisionAgent.name = "MainDecisionAgent" -- 2166
__TS__ClassExtends(MainDecisionAgent, Node) -- 2166
function MainDecisionAgent.prototype.prep(self, shared) -- 2167
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2167
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2167
			return ____awaiter_resolve(nil, {shared = shared}) -- 2167
		end -- 2167
		__TS__Await(maybeProcessPendingMemoryMerge(shared)) -- 2172
		__TS__Await(maybeCompressHistory(shared)) -- 2173
		return ____awaiter_resolve(nil, {shared = shared}) -- 2173
	end) -- 2173
end -- 2167
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2178
	if attempt == nil then -- 2178
		attempt = 1 -- 2181
	end -- 2181
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2181
		if shared.stopToken.stopped then -- 2181
			return ____awaiter_resolve( -- 2181
				nil, -- 2181
				{ -- 2185
					success = false, -- 2185
					message = getCancelledReason(shared) -- 2185
				} -- 2185
			) -- 2185
		end -- 2185
		Log( -- 2187
			"Info", -- 2187
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2187
		) -- 2187
		local tools = buildDecisionToolSchema(shared) -- 2188
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2189
		local stepId = shared.step + 1 -- 2190
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2191
		saveStepLLMDebugInput( -- 2195
			shared, -- 2195
			stepId, -- 2195
			"decision_tool_calling", -- 2195
			messages, -- 2195
			llmOptions -- 2195
		) -- 2195
		local lastStreamContent = "" -- 2196
		local lastStreamReasoning = "" -- 2197
		local res = __TS__Await(callLLMStreamAggregated( -- 2198
			messages, -- 2199
			llmOptions, -- 2200
			shared.stopToken, -- 2201
			shared.llmConfig, -- 2202
			function(response) -- 2203
				local ____opt_39 = response.choices -- 2203
				local ____opt_37 = ____opt_39 and ____opt_39[1] -- 2203
				local streamMessage = ____opt_37 and ____opt_37.message -- 2204
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2205
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2208
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2208
					return -- 2212
				end -- 2212
				lastStreamContent = nextContent -- 2214
				lastStreamReasoning = nextReasoning -- 2215
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2216
			end -- 2203
		)) -- 2203
		if shared.stopToken.stopped then -- 2203
			return ____awaiter_resolve( -- 2203
				nil, -- 2203
				{ -- 2220
					success = false, -- 2220
					message = getCancelledReason(shared) -- 2220
				} -- 2220
			) -- 2220
		end -- 2220
		if not res.success then -- 2220
			saveStepLLMDebugOutput( -- 2223
				shared, -- 2223
				stepId, -- 2223
				"decision_tool_calling", -- 2223
				res.raw or res.message, -- 2223
				{success = false} -- 2223
			) -- 2223
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2224
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2224
		end -- 2224
		saveStepLLMDebugOutput( -- 2227
			shared, -- 2227
			stepId, -- 2227
			"decision_tool_calling", -- 2227
			encodeDebugJSON(res.response), -- 2227
			{success = true} -- 2227
		) -- 2227
		local choice = res.response.choices and res.response.choices[1] -- 2228
		local message = choice and choice.message -- 2229
		local toolCalls = message and message.tool_calls -- 2230
		local toolCall = toolCalls and toolCalls[1] -- 2231
		local fn = toolCall and toolCall["function"] -- 2232
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2233
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 2236
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2239
		Log( -- 2242
			"Info", -- 2242
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2242
		) -- 2242
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2242
			if messageContent and messageContent ~= "" then -- 2242
				Log( -- 2245
					"Info", -- 2245
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2245
				) -- 2245
				return ____awaiter_resolve(nil, { -- 2245
					success = true, -- 2247
					tool = "finish", -- 2248
					params = {}, -- 2249
					reason = messageContent, -- 2250
					reasoningContent = reasoningContent, -- 2251
					directSummary = messageContent -- 2252
				}) -- 2252
			end -- 2252
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2255
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2255
		end -- 2255
		local functionName = fn.name -- 2262
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2263
		Log( -- 2264
			"Info", -- 2264
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2264
		) -- 2264
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2265
			local rawObj, err = safeJsonDecode(argsText) -- 2266
			if err ~= nil or rawObj == nil then -- 2266
				return {__error = tostring(err)} -- 2268
			end -- 2268
			return rawObj -- 2270
		end)() -- 2265
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2265
			local err = tostring(rawArgs.__error) -- 2273
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2274
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2274
		end -- 2274
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2281
		if not decision.success then -- 2281
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2283
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2283
		end -- 2283
		local validation = validateDecision(decision.tool, decision.params) -- 2290
		if not validation.success then -- 2290
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2292
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2292
		end -- 2292
		if not isToolAllowedForRole(shared.role, decision.tool) then -- 2292
			return ____awaiter_resolve(nil, {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText}) -- 2292
		end -- 2292
		decision.params = validation.params -- 2306
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2307
		decision.reason = messageContent -- 2308
		decision.reasoningContent = reasoningContent -- 2309
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2310
		return ____awaiter_resolve(nil, decision) -- 2310
	end) -- 2310
end -- 2178
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2314
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2314
		Log( -- 2319
			"Info", -- 2319
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2319
		) -- 2319
		local lastError = initialError -- 2320
		local candidateRaw = "" -- 2321
		do -- 2321
			local attempt = 0 -- 2322
			while attempt < shared.llmMaxTry do -- 2322
				do -- 2322
					Log( -- 2323
						"Info", -- 2323
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2323
					) -- 2323
					local messages = buildXmlRepairMessages( -- 2324
						shared, -- 2325
						originalRaw, -- 2326
						candidateRaw, -- 2327
						lastError, -- 2328
						attempt + 1 -- 2329
					) -- 2329
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2331
					if shared.stopToken.stopped then -- 2331
						return ____awaiter_resolve( -- 2331
							nil, -- 2331
							{ -- 2333
								success = false, -- 2333
								message = getCancelledReason(shared) -- 2333
							} -- 2333
						) -- 2333
					end -- 2333
					if not llmRes.success then -- 2333
						lastError = llmRes.message -- 2336
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2337
						goto __continue373 -- 2338
					end -- 2338
					candidateRaw = llmRes.text -- 2340
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2341
					if decision.success then -- 2341
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2343
						return ____awaiter_resolve(nil, decision) -- 2343
					end -- 2343
					lastError = decision.message -- 2346
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2347
				end -- 2347
				::__continue373:: -- 2347
				attempt = attempt + 1 -- 2322
			end -- 2322
		end -- 2322
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2349
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2349
	end) -- 2349
end -- 2314
function MainDecisionAgent.prototype.exec(self, input) -- 2357
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2357
		local shared = input.shared -- 2358
		if shared.stopToken.stopped then -- 2358
			return ____awaiter_resolve( -- 2358
				nil, -- 2358
				{ -- 2360
					success = false, -- 2360
					message = getCancelledReason(shared) -- 2360
				} -- 2360
			) -- 2360
		end -- 2360
		if shared.step >= shared.maxSteps then -- 2360
			Log( -- 2363
				"Warn", -- 2363
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2363
			) -- 2363
			return ____awaiter_resolve( -- 2363
				nil, -- 2363
				{ -- 2364
					success = false, -- 2364
					message = getMaxStepsReachedReason(shared) -- 2364
				} -- 2364
			) -- 2364
		end -- 2364
		if shared.decisionMode == "tool_calling" then -- 2364
			Log( -- 2368
				"Info", -- 2368
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2368
			) -- 2368
			local lastError = "tool calling validation failed" -- 2369
			local lastRaw = "" -- 2370
			do -- 2370
				local attempt = 0 -- 2371
				while attempt < shared.llmMaxTry do -- 2371
					Log( -- 2372
						"Info", -- 2372
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2372
					) -- 2372
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2373
					if shared.stopToken.stopped then -- 2373
						return ____awaiter_resolve( -- 2373
							nil, -- 2373
							{ -- 2380
								success = false, -- 2380
								message = getCancelledReason(shared) -- 2380
							} -- 2380
						) -- 2380
					end -- 2380
					if decision.success then -- 2380
						return ____awaiter_resolve(nil, decision) -- 2380
					end -- 2380
					lastError = decision.message -- 2385
					lastRaw = decision.raw or "" -- 2386
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2387
					attempt = attempt + 1 -- 2371
				end -- 2371
			end -- 2371
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2389
			return ____awaiter_resolve( -- 2389
				nil, -- 2389
				{ -- 2390
					success = false, -- 2390
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2390
				} -- 2390
			) -- 2390
		end -- 2390
		local lastError = "xml validation failed" -- 2393
		local lastRaw = "" -- 2394
		do -- 2394
			local attempt = 0 -- 2395
			while attempt < shared.llmMaxTry do -- 2395
				do -- 2395
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2396
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2404
					if shared.stopToken.stopped then -- 2404
						return ____awaiter_resolve( -- 2404
							nil, -- 2404
							{ -- 2406
								success = false, -- 2406
								message = getCancelledReason(shared) -- 2406
							} -- 2406
						) -- 2406
					end -- 2406
					if not llmRes.success then -- 2406
						lastError = llmRes.message -- 2409
						lastRaw = llmRes.text or "" -- 2410
						goto __continue386 -- 2411
					end -- 2411
					lastRaw = llmRes.text -- 2413
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2414
					if decision.success then -- 2414
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2414
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2417
							return ____awaiter_resolve( -- 2417
								nil, -- 2417
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2418
							) -- 2418
						end -- 2418
						return ____awaiter_resolve(nil, decision) -- 2418
					end -- 2418
					lastError = decision.message -- 2422
					return ____awaiter_resolve( -- 2422
						nil, -- 2422
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2423
					) -- 2423
				end -- 2423
				::__continue386:: -- 2423
				attempt = attempt + 1 -- 2395
			end -- 2395
		end -- 2395
		return ____awaiter_resolve( -- 2395
			nil, -- 2395
			{ -- 2425
				success = false, -- 2425
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2425
			} -- 2425
		) -- 2425
	end) -- 2425
end -- 2357
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2428
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2428
		local result = execRes -- 2429
		if not result.success then -- 2429
			if shared.stopToken.stopped then -- 2429
				shared.error = getCancelledReason(shared) -- 2432
				shared.done = true -- 2433
				return ____awaiter_resolve(nil, "done") -- 2433
			end -- 2433
			shared.error = result.message -- 2436
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2437
			shared.done = true -- 2438
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2439
			persistHistoryState(shared) -- 2443
			return ____awaiter_resolve(nil, "done") -- 2443
		end -- 2443
		if result.directSummary and result.directSummary ~= "" then -- 2443
			shared.response = result.directSummary -- 2447
			shared.done = true -- 2448
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2449
			persistHistoryState(shared) -- 2454
			return ____awaiter_resolve(nil, "done") -- 2454
		end -- 2454
		if result.tool == "finish" then -- 2454
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2458
			shared.response = finalMessage -- 2459
			shared.done = true -- 2460
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2461
			persistHistoryState(shared) -- 2466
			return ____awaiter_resolve(nil, "done") -- 2466
		end -- 2466
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2469
		shared.step = shared.step + 1 -- 2470
		local step = shared.step -- 2471
		emitAgentEvent(shared, { -- 2472
			type = "decision_made", -- 2473
			sessionId = shared.sessionId, -- 2474
			taskId = shared.taskId, -- 2475
			step = step, -- 2476
			tool = result.tool, -- 2477
			reason = result.reason, -- 2478
			reasoningContent = result.reasoningContent, -- 2479
			params = result.params -- 2480
		}) -- 2480
		local ____shared_history_45 = shared.history -- 2480
		____shared_history_45[#____shared_history_45 + 1] = { -- 2482
			step = step, -- 2483
			toolCallId = toolCallId, -- 2484
			tool = result.tool, -- 2485
			reason = result.reason or "", -- 2486
			reasoningContent = result.reasoningContent, -- 2487
			params = result.params, -- 2488
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2489
		} -- 2489
		appendConversationMessage( -- 2491
			shared, -- 2491
			{ -- 2491
				role = "assistant", -- 2492
				content = result.reason or "", -- 2493
				reasoning_content = result.reasoningContent, -- 2494
				tool_calls = {{ -- 2495
					id = toolCallId, -- 2496
					type = "function", -- 2497
					["function"] = { -- 2498
						name = result.tool, -- 2499
						arguments = toJson(result.params) -- 2500
					} -- 2500
				}} -- 2500
			} -- 2500
		) -- 2500
		persistHistoryState(shared) -- 2504
		return ____awaiter_resolve(nil, result.tool) -- 2504
	end) -- 2504
end -- 2428
local ReadFileAction = __TS__Class() -- 2509
ReadFileAction.name = "ReadFileAction" -- 2509
__TS__ClassExtends(ReadFileAction, Node) -- 2509
function ReadFileAction.prototype.prep(self, shared) -- 2510
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2510
		local last = shared.history[#shared.history] -- 2511
		if not last then -- 2511
			error( -- 2512
				__TS__New(Error, "no history"), -- 2512
				0 -- 2512
			) -- 2512
		end -- 2512
		emitAgentStartEvent(shared, last) -- 2513
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2514
		if __TS__StringTrim(path) == "" then -- 2514
			error( -- 2517
				__TS__New(Error, "missing path"), -- 2517
				0 -- 2517
			) -- 2517
		end -- 2517
		local ____path_48 = path -- 2519
		local ____shared_workingDir_49 = shared.workingDir -- 2521
		local ____temp_50 = shared.useChineseResponse and "zh" or "en" -- 2522
		local ____last_params_startLine_46 = last.params.startLine -- 2523
		if ____last_params_startLine_46 == nil then -- 2523
			____last_params_startLine_46 = 1 -- 2523
		end -- 2523
		local ____TS__Number_result_51 = __TS__Number(____last_params_startLine_46) -- 2523
		local ____last_params_endLine_47 = last.params.endLine -- 2524
		if ____last_params_endLine_47 == nil then -- 2524
			____last_params_endLine_47 = READ_FILE_DEFAULT_LIMIT -- 2524
		end -- 2524
		return ____awaiter_resolve( -- 2524
			nil, -- 2524
			{ -- 2518
				path = ____path_48, -- 2519
				tool = "read_file", -- 2520
				workDir = ____shared_workingDir_49, -- 2521
				docLanguage = ____temp_50, -- 2522
				startLine = ____TS__Number_result_51, -- 2523
				endLine = __TS__Number(____last_params_endLine_47) -- 2524
			} -- 2524
		) -- 2524
	end) -- 2524
end -- 2510
function ReadFileAction.prototype.exec(self, input) -- 2528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2528
		return ____awaiter_resolve( -- 2528
			nil, -- 2528
			Tools.readFile( -- 2529
				input.workDir, -- 2530
				input.path, -- 2531
				__TS__Number(input.startLine or 1), -- 2532
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2533
				input.docLanguage -- 2534
			) -- 2534
		) -- 2534
	end) -- 2534
end -- 2528
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2538
		local result = execRes -- 2539
		local last = shared.history[#shared.history] -- 2540
		if last ~= nil then -- 2540
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2542
			appendToolResultMessage(shared, last) -- 2543
			emitAgentFinishEvent(shared, last) -- 2544
		end -- 2544
		persistHistoryState(shared) -- 2546
		__TS__Await(maybeCompressHistory(shared)) -- 2547
		persistHistoryState(shared) -- 2548
		return ____awaiter_resolve(nil, "main") -- 2548
	end) -- 2548
end -- 2538
local SearchFilesAction = __TS__Class() -- 2553
SearchFilesAction.name = "SearchFilesAction" -- 2553
__TS__ClassExtends(SearchFilesAction, Node) -- 2553
function SearchFilesAction.prototype.prep(self, shared) -- 2554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2554
		local last = shared.history[#shared.history] -- 2555
		if not last then -- 2555
			error( -- 2556
				__TS__New(Error, "no history"), -- 2556
				0 -- 2556
			) -- 2556
		end -- 2556
		emitAgentStartEvent(shared, last) -- 2557
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2557
	end) -- 2557
end -- 2554
function SearchFilesAction.prototype.exec(self, input) -- 2561
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2561
		local params = input.params -- 2562
		local ____Tools_searchFiles_65 = Tools.searchFiles -- 2563
		local ____input_workDir_58 = input.workDir -- 2564
		local ____temp_59 = params.path or "" -- 2565
		local ____temp_60 = params.pattern or "" -- 2566
		local ____params_globs_61 = params.globs -- 2567
		local ____params_useRegex_62 = params.useRegex -- 2568
		local ____params_caseSensitive_63 = params.caseSensitive -- 2569
		local ____math_max_54 = math.max -- 2572
		local ____math_floor_53 = math.floor -- 2572
		local ____params_limit_52 = params.limit -- 2572
		if ____params_limit_52 == nil then -- 2572
			____params_limit_52 = SEARCH_FILES_LIMIT_DEFAULT -- 2572
		end -- 2572
		local ____math_max_54_result_64 = ____math_max_54( -- 2572
			1, -- 2572
			____math_floor_53(__TS__Number(____params_limit_52)) -- 2572
		) -- 2572
		local ____math_max_57 = math.max -- 2573
		local ____math_floor_56 = math.floor -- 2573
		local ____params_offset_55 = params.offset -- 2573
		if ____params_offset_55 == nil then -- 2573
			____params_offset_55 = 0 -- 2573
		end -- 2573
		local result = __TS__Await(____Tools_searchFiles_65({ -- 2563
			workDir = ____input_workDir_58, -- 2564
			path = ____temp_59, -- 2565
			pattern = ____temp_60, -- 2566
			globs = ____params_globs_61, -- 2567
			useRegex = ____params_useRegex_62, -- 2568
			caseSensitive = ____params_caseSensitive_63, -- 2569
			includeContent = true, -- 2570
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2571
			limit = ____math_max_54_result_64, -- 2572
			offset = ____math_max_57( -- 2573
				0, -- 2573
				____math_floor_56(__TS__Number(____params_offset_55)) -- 2573
			), -- 2573
			groupByFile = params.groupByFile == true -- 2574
		})) -- 2574
		return ____awaiter_resolve(nil, result) -- 2574
	end) -- 2574
end -- 2561
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2579
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2579
		local last = shared.history[#shared.history] -- 2580
		if last ~= nil then -- 2580
			local result = execRes -- 2582
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2583
			appendToolResultMessage(shared, last) -- 2584
			emitAgentFinishEvent(shared, last) -- 2585
		end -- 2585
		persistHistoryState(shared) -- 2587
		__TS__Await(maybeCompressHistory(shared)) -- 2588
		persistHistoryState(shared) -- 2589
		return ____awaiter_resolve(nil, "main") -- 2589
	end) -- 2589
end -- 2579
local SearchDoraAPIAction = __TS__Class() -- 2594
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2594
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2594
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2595
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2595
		local last = shared.history[#shared.history] -- 2596
		if not last then -- 2596
			error( -- 2597
				__TS__New(Error, "no history"), -- 2597
				0 -- 2597
			) -- 2597
		end -- 2597
		emitAgentStartEvent(shared, last) -- 2598
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2598
	end) -- 2598
end -- 2595
function SearchDoraAPIAction.prototype.exec(self, input) -- 2602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2602
		local params = input.params -- 2603
		local ____Tools_searchDoraAPI_73 = Tools.searchDoraAPI -- 2604
		local ____temp_69 = params.pattern or "" -- 2605
		local ____temp_70 = params.docSource or "api" -- 2606
		local ____temp_71 = input.useChineseResponse and "zh" or "en" -- 2607
		local ____temp_72 = params.programmingLanguage or "ts" -- 2608
		local ____math_min_68 = math.min -- 2609
		local ____math_max_67 = math.max -- 2609
		local ____params_limit_66 = params.limit -- 2609
		if ____params_limit_66 == nil then -- 2609
			____params_limit_66 = 8 -- 2609
		end -- 2609
		local result = __TS__Await(____Tools_searchDoraAPI_73({ -- 2604
			pattern = ____temp_69, -- 2605
			docSource = ____temp_70, -- 2606
			docLanguage = ____temp_71, -- 2607
			programmingLanguage = ____temp_72, -- 2608
			limit = ____math_min_68( -- 2609
				SEARCH_DORA_API_LIMIT_MAX, -- 2609
				____math_max_67( -- 2609
					1, -- 2609
					__TS__Number(____params_limit_66) -- 2609
				) -- 2609
			), -- 2609
			useRegex = params.useRegex, -- 2610
			caseSensitive = false, -- 2611
			includeContent = true, -- 2612
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2613
		})) -- 2613
		return ____awaiter_resolve(nil, result) -- 2613
	end) -- 2613
end -- 2602
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2618
		local last = shared.history[#shared.history] -- 2619
		if last ~= nil then -- 2619
			local result = execRes -- 2621
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2622
			appendToolResultMessage(shared, last) -- 2623
			emitAgentFinishEvent(shared, last) -- 2624
		end -- 2624
		persistHistoryState(shared) -- 2626
		__TS__Await(maybeCompressHistory(shared)) -- 2627
		persistHistoryState(shared) -- 2628
		return ____awaiter_resolve(nil, "main") -- 2628
	end) -- 2628
end -- 2618
local ListFilesAction = __TS__Class() -- 2633
ListFilesAction.name = "ListFilesAction" -- 2633
__TS__ClassExtends(ListFilesAction, Node) -- 2633
function ListFilesAction.prototype.prep(self, shared) -- 2634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2634
		local last = shared.history[#shared.history] -- 2635
		if not last then -- 2635
			error( -- 2636
				__TS__New(Error, "no history"), -- 2636
				0 -- 2636
			) -- 2636
		end -- 2636
		emitAgentStartEvent(shared, last) -- 2637
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2637
	end) -- 2637
end -- 2634
function ListFilesAction.prototype.exec(self, input) -- 2641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2641
		local params = input.params -- 2642
		local ____Tools_listFiles_80 = Tools.listFiles -- 2643
		local ____input_workDir_77 = input.workDir -- 2644
		local ____temp_78 = params.path or "" -- 2645
		local ____params_globs_79 = params.globs -- 2646
		local ____math_max_76 = math.max -- 2647
		local ____math_floor_75 = math.floor -- 2647
		local ____params_maxEntries_74 = params.maxEntries -- 2647
		if ____params_maxEntries_74 == nil then -- 2647
			____params_maxEntries_74 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2647
		end -- 2647
		local result = ____Tools_listFiles_80({ -- 2643
			workDir = ____input_workDir_77, -- 2644
			path = ____temp_78, -- 2645
			globs = ____params_globs_79, -- 2646
			maxEntries = ____math_max_76( -- 2647
				1, -- 2647
				____math_floor_75(__TS__Number(____params_maxEntries_74)) -- 2647
			) -- 2647
		}) -- 2647
		return ____awaiter_resolve(nil, result) -- 2647
	end) -- 2647
end -- 2641
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2652
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2652
		local last = shared.history[#shared.history] -- 2653
		if last ~= nil then -- 2653
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2655
			appendToolResultMessage(shared, last) -- 2656
			emitAgentFinishEvent(shared, last) -- 2657
		end -- 2657
		persistHistoryState(shared) -- 2659
		__TS__Await(maybeCompressHistory(shared)) -- 2660
		persistHistoryState(shared) -- 2661
		return ____awaiter_resolve(nil, "main") -- 2661
	end) -- 2661
end -- 2652
local DeleteFileAction = __TS__Class() -- 2666
DeleteFileAction.name = "DeleteFileAction" -- 2666
__TS__ClassExtends(DeleteFileAction, Node) -- 2666
function DeleteFileAction.prototype.prep(self, shared) -- 2667
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2667
		local last = shared.history[#shared.history] -- 2668
		if not last then -- 2668
			error( -- 2669
				__TS__New(Error, "no history"), -- 2669
				0 -- 2669
			) -- 2669
		end -- 2669
		emitAgentStartEvent(shared, last) -- 2670
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2671
		if __TS__StringTrim(targetFile) == "" then -- 2671
			error( -- 2674
				__TS__New(Error, "missing target_file"), -- 2674
				0 -- 2674
			) -- 2674
		end -- 2674
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2674
	end) -- 2674
end -- 2667
function DeleteFileAction.prototype.exec(self, input) -- 2678
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2678
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2679
		if not result.success then -- 2679
			return ____awaiter_resolve(nil, result) -- 2679
		end -- 2679
		return ____awaiter_resolve(nil, { -- 2679
			success = true, -- 2687
			changed = true, -- 2688
			mode = "delete", -- 2689
			checkpointId = result.checkpointId, -- 2690
			checkpointSeq = result.checkpointSeq, -- 2691
			files = {{path = input.targetFile, op = "delete"}} -- 2692
		}) -- 2692
	end) -- 2692
end -- 2678
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2696
		local last = shared.history[#shared.history] -- 2697
		if last ~= nil then -- 2697
			last.result = execRes -- 2699
			appendToolResultMessage(shared, last) -- 2700
			emitAgentFinishEvent(shared, last) -- 2701
			local result = last.result -- 2702
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2702
				emitAgentEvent(shared, { -- 2707
					type = "checkpoint_created", -- 2708
					sessionId = shared.sessionId, -- 2709
					taskId = shared.taskId, -- 2710
					step = last.step, -- 2711
					tool = "delete_file", -- 2712
					checkpointId = result.checkpointId, -- 2713
					checkpointSeq = result.checkpointSeq, -- 2714
					files = result.files -- 2715
				}) -- 2715
			end -- 2715
		end -- 2715
		persistHistoryState(shared) -- 2719
		__TS__Await(maybeCompressHistory(shared)) -- 2720
		persistHistoryState(shared) -- 2721
		return ____awaiter_resolve(nil, "main") -- 2721
	end) -- 2721
end -- 2696
local BuildAction = __TS__Class() -- 2726
BuildAction.name = "BuildAction" -- 2726
__TS__ClassExtends(BuildAction, Node) -- 2726
function BuildAction.prototype.prep(self, shared) -- 2727
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2727
		local last = shared.history[#shared.history] -- 2728
		if not last then -- 2728
			error( -- 2729
				__TS__New(Error, "no history"), -- 2729
				0 -- 2729
			) -- 2729
		end -- 2729
		emitAgentStartEvent(shared, last) -- 2730
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2730
	end) -- 2730
end -- 2727
function BuildAction.prototype.exec(self, input) -- 2734
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2734
		local params = input.params -- 2735
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2736
		return ____awaiter_resolve(nil, result) -- 2736
	end) -- 2736
end -- 2734
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2743
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2743
		local last = shared.history[#shared.history] -- 2744
		if last ~= nil then -- 2744
			last.result = execRes -- 2746
			appendToolResultMessage(shared, last) -- 2747
			emitAgentFinishEvent(shared, last) -- 2748
		end -- 2748
		persistHistoryState(shared) -- 2750
		__TS__Await(maybeCompressHistory(shared)) -- 2751
		persistHistoryState(shared) -- 2752
		return ____awaiter_resolve(nil, "main") -- 2752
	end) -- 2752
end -- 2743
local SpawnSubAgentAction = __TS__Class() -- 2757
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2757
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2757
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2758
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2758
		local last = shared.history[#shared.history] -- 2767
		if not last then -- 2767
			error( -- 2768
				__TS__New(Error, "no history"), -- 2768
				0 -- 2768
			) -- 2768
		end -- 2768
		emitAgentStartEvent(shared, last) -- 2769
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2770
			last.params.filesHint, -- 2771
			function(____, item) return type(item) == "string" end -- 2771
		) or nil -- 2771
		return ____awaiter_resolve( -- 2771
			nil, -- 2771
			{ -- 2773
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2774
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2775
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2776
				filesHint = filesHint, -- 2777
				sessionId = shared.sessionId, -- 2778
				projectRoot = shared.workingDir, -- 2779
				spawnSubAgent = shared.spawnSubAgent -- 2780
			} -- 2780
		) -- 2780
	end) -- 2780
end -- 2758
function SpawnSubAgentAction.prototype.exec(self, input) -- 2784
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2784
		if not input.spawnSubAgent then -- 2784
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2784
		end -- 2784
		if input.sessionId == nil or input.sessionId <= 0 then -- 2784
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2784
		end -- 2784
		local ____Log_86 = Log -- 2799
		local ____temp_83 = #input.title -- 2799
		local ____temp_84 = #input.prompt -- 2799
		local ____temp_85 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2799
		local ____opt_81 = input.filesHint -- 2799
		____Log_86( -- 2799
			"Info", -- 2799
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_83)) .. " prompt_len=") .. tostring(____temp_84)) .. " expected_len=") .. tostring(____temp_85)) .. " files_hint_count=") .. tostring(____opt_81 and #____opt_81 or 0) -- 2799
		) -- 2799
		local result = __TS__Await(input:spawnSubAgent({ -- 2800
			parentSessionId = input.sessionId, -- 2801
			projectRoot = input.projectRoot, -- 2802
			title = input.title, -- 2803
			prompt = input.prompt, -- 2804
			expectedOutput = input.expectedOutput, -- 2805
			filesHint = input.filesHint -- 2806
		})) -- 2806
		if not result.success then -- 2806
			return ____awaiter_resolve(nil, result) -- 2806
		end -- 2806
		return ____awaiter_resolve(nil, {success = true, sessionId = result.sessionId, taskId = result.taskId, title = result.title}) -- 2806
	end) -- 2806
end -- 2784
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 2819
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2819
		local last = shared.history[#shared.history] -- 2820
		if last ~= nil then -- 2820
			last.result = execRes -- 2822
			appendToolResultMessage(shared, last) -- 2823
			emitAgentFinishEvent(shared, last) -- 2824
		end -- 2824
		persistHistoryState(shared) -- 2826
		__TS__Await(maybeCompressHistory(shared)) -- 2827
		persistHistoryState(shared) -- 2828
		return ____awaiter_resolve(nil, "main") -- 2828
	end) -- 2828
end -- 2819
local EditFileAction = __TS__Class() -- 2833
EditFileAction.name = "EditFileAction" -- 2833
__TS__ClassExtends(EditFileAction, Node) -- 2833
function EditFileAction.prototype.prep(self, shared) -- 2834
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2834
		local last = shared.history[#shared.history] -- 2835
		if not last then -- 2835
			error( -- 2836
				__TS__New(Error, "no history"), -- 2836
				0 -- 2836
			) -- 2836
		end -- 2836
		emitAgentStartEvent(shared, last) -- 2837
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2838
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2841
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2842
		if __TS__StringTrim(path) == "" then -- 2842
			error( -- 2843
				__TS__New(Error, "missing path"), -- 2843
				0 -- 2843
			) -- 2843
		end -- 2843
		return ____awaiter_resolve(nil, { -- 2843
			path = path, -- 2844
			oldStr = oldStr, -- 2844
			newStr = newStr, -- 2844
			taskId = shared.taskId, -- 2844
			workDir = shared.workingDir -- 2844
		}) -- 2844
	end) -- 2844
end -- 2834
function EditFileAction.prototype.exec(self, input) -- 2847
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2847
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2848
		if not readRes.success then -- 2848
			if input.oldStr ~= "" then -- 2848
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2848
			end -- 2848
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2853
			if not createRes.success then -- 2853
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2853
			end -- 2853
			return ____awaiter_resolve(nil, { -- 2853
				success = true, -- 2861
				changed = true, -- 2862
				mode = "create", -- 2863
				checkpointId = createRes.checkpointId, -- 2864
				checkpointSeq = createRes.checkpointSeq, -- 2865
				files = {{path = input.path, op = "create"}} -- 2866
			}) -- 2866
		end -- 2866
		if input.oldStr == "" then -- 2866
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2870
			if not overwriteRes.success then -- 2870
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2870
			end -- 2870
			return ____awaiter_resolve(nil, { -- 2870
				success = true, -- 2878
				changed = true, -- 2879
				mode = "overwrite", -- 2880
				checkpointId = overwriteRes.checkpointId, -- 2881
				checkpointSeq = overwriteRes.checkpointSeq, -- 2882
				files = {{path = input.path, op = "write"}} -- 2883
			}) -- 2883
		end -- 2883
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2888
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2889
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2890
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2893
		if occurrences == 0 then -- 2893
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2895
			if not indentTolerant.success then -- 2895
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2895
			end -- 2895
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2899
			if not applyRes.success then -- 2899
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2899
			end -- 2899
			return ____awaiter_resolve(nil, { -- 2899
				success = true, -- 2907
				changed = true, -- 2908
				mode = "replace_indent_tolerant", -- 2909
				checkpointId = applyRes.checkpointId, -- 2910
				checkpointSeq = applyRes.checkpointSeq, -- 2911
				files = {{path = input.path, op = "write"}} -- 2912
			}) -- 2912
		end -- 2912
		if occurrences > 1 then -- 2912
			return ____awaiter_resolve( -- 2912
				nil, -- 2912
				{ -- 2916
					success = false, -- 2916
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2916
				} -- 2916
			) -- 2916
		end -- 2916
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2920
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2921
		if not applyRes.success then -- 2921
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2921
		end -- 2921
		return ____awaiter_resolve(nil, { -- 2921
			success = true, -- 2929
			changed = true, -- 2930
			mode = "replace", -- 2931
			checkpointId = applyRes.checkpointId, -- 2932
			checkpointSeq = applyRes.checkpointSeq, -- 2933
			files = {{path = input.path, op = "write"}} -- 2934
		}) -- 2934
	end) -- 2934
end -- 2847
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2938
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2938
		local last = shared.history[#shared.history] -- 2939
		if last ~= nil then -- 2939
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2941
			last.result = execRes -- 2942
			appendToolResultMessage(shared, last) -- 2943
			emitAgentFinishEvent(shared, last) -- 2944
			local result = last.result -- 2945
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2945
				emitAgentEvent(shared, { -- 2950
					type = "checkpoint_created", -- 2951
					sessionId = shared.sessionId, -- 2952
					taskId = shared.taskId, -- 2953
					step = last.step, -- 2954
					tool = last.tool, -- 2955
					checkpointId = result.checkpointId, -- 2956
					checkpointSeq = result.checkpointSeq, -- 2957
					files = result.files -- 2958
				}) -- 2958
			end -- 2958
		end -- 2958
		persistHistoryState(shared) -- 2962
		__TS__Await(maybeCompressHistory(shared)) -- 2963
		persistHistoryState(shared) -- 2964
		return ____awaiter_resolve(nil, "main") -- 2964
	end) -- 2964
end -- 2938
local EndNode = __TS__Class() -- 2969
EndNode.name = "EndNode" -- 2969
__TS__ClassExtends(EndNode, Node) -- 2969
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2970
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2970
		return ____awaiter_resolve(nil, nil) -- 2970
	end) -- 2970
end -- 2970
local CodingAgentFlow = __TS__Class() -- 2975
CodingAgentFlow.name = "CodingAgentFlow" -- 2975
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2975
function CodingAgentFlow.prototype.____constructor(self, role) -- 2976
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2977
	local read = __TS__New(ReadFileAction, 1, 0) -- 2978
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2979
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2980
	local list = __TS__New(ListFilesAction, 1, 0) -- 2981
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2982
	local build = __TS__New(BuildAction, 1, 0) -- 2983
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 2984
	local edit = __TS__New(EditFileAction, 1, 0) -- 2985
	local done = __TS__New(EndNode, 1, 0) -- 2986
	main:on("grep_files", search) -- 2988
	main:on("search_dora_api", searchDora) -- 2989
	main:on("glob_files", list) -- 2990
	if role == "main" then -- 2990
		main:on("read_file", read) -- 2992
		main:on("spawn_sub_agent", spawn) -- 2993
	else -- 2993
		main:on("read_file", read) -- 2995
		main:on("delete_file", del) -- 2996
		main:on("build", build) -- 2997
		main:on("edit_file", edit) -- 2998
	end -- 2998
	main:on("done", done) -- 3000
	search:on("main", main) -- 3002
	searchDora:on("main", main) -- 3003
	list:on("main", main) -- 3004
	spawn:on("main", main) -- 3005
	read:on("main", main) -- 3006
	del:on("main", main) -- 3007
	build:on("main", main) -- 3008
	edit:on("main", main) -- 3009
	Flow.prototype.____constructor(self, main) -- 3011
end -- 2976
local function runCodingAgentAsync(options) -- 3033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3033
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3033
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3033
		end -- 3033
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3037
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3038
		if not llmConfigRes.success then -- 3038
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3038
		end -- 3038
		local llmConfig = llmConfigRes.config -- 3044
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3045
		if not taskRes.success then -- 3045
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3045
		end -- 3045
		local compressor = __TS__New(MemoryCompressor, { -- 3052
			compressionThreshold = 0.8, -- 3053
			compressionTargetThreshold = 0.5, -- 3054
			maxCompressionRounds = 3, -- 3055
			projectDir = options.workDir, -- 3056
			llmConfig = llmConfig, -- 3057
			promptPack = options.promptPack, -- 3058
			scope = options.memoryScope -- 3059
		}) -- 3059
		local persistedSession = compressor:getStorage():readSessionState() -- 3061
		local promptPack = compressor:getPromptPack() -- 3062
		local shared = { -- 3064
			sessionId = options.sessionId, -- 3065
			taskId = taskRes.taskId, -- 3066
			role = options.role or "main", -- 3067
			maxSteps = math.max( -- 3068
				1, -- 3068
				math.floor(options.maxSteps or 50) -- 3068
			), -- 3068
			llmMaxTry = math.max( -- 3069
				1, -- 3069
				math.floor(options.llmMaxTry or 5) -- 3069
			), -- 3069
			step = 0, -- 3070
			done = false, -- 3071
			stopToken = options.stopToken or ({stopped = false}), -- 3072
			response = "", -- 3073
			userQuery = normalizedPrompt, -- 3074
			workingDir = options.workDir, -- 3075
			useChineseResponse = options.useChineseResponse == true, -- 3076
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3077
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 3080
			llmConfig = llmConfig, -- 3085
			onEvent = options.onEvent, -- 3086
			promptPack = promptPack, -- 3087
			history = {}, -- 3088
			messages = persistedSession.messages, -- 3089
			memory = {compressor = compressor}, -- 3091
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3095
			spawnSubAgent = options.spawnSubAgent -- 3100
		} -- 3100
		local ____try = __TS__AsyncAwaiter(function() -- 3100
			emitAgentEvent(shared, { -- 3104
				type = "task_started", -- 3105
				sessionId = shared.sessionId, -- 3106
				taskId = shared.taskId, -- 3107
				prompt = shared.userQuery, -- 3108
				workDir = shared.workingDir, -- 3109
				maxSteps = shared.maxSteps -- 3110
			}) -- 3110
			if shared.stopToken.stopped then -- 3110
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3113
				return ____awaiter_resolve( -- 3113
					nil, -- 3113
					emitAgentTaskFinishEvent( -- 3114
						shared, -- 3114
						false, -- 3114
						getCancelledReason(shared) -- 3114
					) -- 3114
				) -- 3114
			end -- 3114
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3116
			local promptCommand = getPromptCommand(shared.userQuery) -- 3117
			if promptCommand == "reset" then -- 3117
				return ____awaiter_resolve( -- 3117
					nil, -- 3117
					resetSessionHistory(shared) -- 3119
				) -- 3119
			end -- 3119
			if promptCommand == "compact" then -- 3119
				return ____awaiter_resolve( -- 3119
					nil, -- 3119
					__TS__Await(compactAllHistory(shared)) -- 3122
				) -- 3122
			end -- 3122
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3124
			persistHistoryState(shared) -- 3128
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3129
			__TS__Await(flow:run(shared)) -- 3130
			if shared.stopToken.stopped then -- 3130
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3132
				return ____awaiter_resolve( -- 3132
					nil, -- 3132
					emitAgentTaskFinishEvent( -- 3133
						shared, -- 3133
						false, -- 3133
						getCancelledReason(shared) -- 3133
					) -- 3133
				) -- 3133
			end -- 3133
			if shared.error then -- 3133
				return ____awaiter_resolve( -- 3133
					nil, -- 3133
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3136
				) -- 3136
			end -- 3136
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3139
			return ____awaiter_resolve( -- 3139
				nil, -- 3139
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3140
			) -- 3140
		end) -- 3140
		__TS__Await(____try.catch( -- 3103
			____try, -- 3103
			function(____, e) -- 3103
				return ____awaiter_resolve( -- 3103
					nil, -- 3103
					finalizeAgentFailure( -- 3143
						shared, -- 3143
						tostring(e) -- 3143
					) -- 3143
				) -- 3143
			end -- 3143
		)) -- 3143
	end) -- 3143
end -- 3033
function ____exports.runCodingAgent(options, callback) -- 3147
	local ____self_87 = runCodingAgentAsync(options) -- 3147
	____self_87["then"]( -- 3147
		____self_87, -- 3147
		function(____, result) return callback(result) end -- 3148
	) -- 3148
end -- 3147
return ____exports -- 3147