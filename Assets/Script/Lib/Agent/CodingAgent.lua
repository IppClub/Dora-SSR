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
function emitAgentEvent(shared, event) -- 666
	if shared.onEvent then -- 666
		do -- 666
			local function ____catch(____error) -- 666
				Log( -- 671
					"Error", -- 671
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 671
				) -- 671
			end -- 671
			local ____try, ____hasReturned = pcall(function() -- 671
				shared:onEvent(event) -- 669
			end) -- 669
			if not ____try then -- 669
				____catch(____hasReturned) -- 669
			end -- 669
		end -- 669
	end -- 669
end -- 669
function truncateText(text, maxLen) -- 915
	if #text <= maxLen then -- 915
		return text -- 916
	end -- 916
	local nextPos = utf8.offset(text, maxLen + 1) -- 917
	if nextPos == nil then -- 917
		return text -- 918
	end -- 918
	return string.sub(text, 1, nextPos - 1) .. "..." -- 919
end -- 919
function getReplyLanguageDirective(shared) -- 929
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 930
end -- 930
function replacePromptVars(template, vars) -- 935
	local output = template -- 936
	for key in pairs(vars) do -- 937
		output = table.concat( -- 938
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 938
			vars[key] or "" or "," -- 938
		) -- 938
	end -- 938
	return output -- 940
end -- 940
function getDecisionToolDefinitions(shared) -- 1064
	local base = replacePromptVars( -- 1065
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1066
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1067
	) -- 1067
	local spawnTool = "\n\n9. spawn_sub_agent: Create and start a sub agent session for implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this whenever the task requires direct coding, file editing, file deletion, build verification, documentation writing, or any other concrete execution work by a delegated sub agent.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- filesHint is an optional list of likely files or directories." -- 1069
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1078
		getAllowedToolsForRole(shared.role), -- 1079
		", " -- 1079
	) or "" -- 1079
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1081
	if (shared and shared.decisionMode) ~= "xml" then -- 1081
		return withRole -- 1083
	end -- 1083
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1085
end -- 1085
function persistHistoryState(shared) -- 1334
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 1335
end -- 1335
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 1417
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 1422
	if carryMessage then -- 1422
		__TS__ArrayUnshift( -- 1424
			remainingMessages, -- 1424
			__TS__ObjectAssign( -- 1424
				{}, -- 1424
				carryMessage, -- 1425
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1424
			) -- 1424
		) -- 1424
	end -- 1424
	shared.messages = remainingMessages -- 1429
end -- 1429
function getAllowedToolsForRole(role) -- 1706
	return role == "main" and ({ -- 1707
		"read_file", -- 1708
		"grep_files", -- 1708
		"search_dora_api", -- 1708
		"glob_files", -- 1708
		"spawn_sub_agent", -- 1708
		"finish" -- 1708
	}) or ({ -- 1708
		"read_file", -- 1709
		"edit_file", -- 1709
		"delete_file", -- 1709
		"grep_files", -- 1709
		"search_dora_api", -- 1709
		"glob_files", -- 1709
		"build", -- 1709
		"finish" -- 1709
	}) -- 1709
end -- 1709
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1805
	if includeToolDefinitions == nil then -- 1805
		includeToolDefinitions = false -- 1805
	end -- 1805
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase using search/discovery tools, and decide when to delegate implementation work by spawning sub agents.\n\nRules:\n- Do not perform direct code editing, deletion, or build actions yourself.\n- Use spawn_sub_agent when the task requires concrete implementation or verification work.\n- Code changes, file deletion, build/compile verification, and documentation writing should be delegated to a sub agent.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 1806
	local sections = { -- 1826
		shared.promptPack.agentIdentityPrompt, -- 1827
		rolePrompt, -- 1828
		getReplyLanguageDirective(shared) -- 1829
	} -- 1829
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1831
	if memoryContext ~= "" then -- 1831
		sections[#sections + 1] = memoryContext -- 1833
	end -- 1833
	if includeToolDefinitions then -- 1833
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1836
		if shared.decisionMode == "xml" then -- 1836
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1838
		end -- 1838
	end -- 1838
	local skillsSection = buildSkillsSection(shared) -- 1842
	if skillsSection ~= "" then -- 1842
		sections[#sections + 1] = skillsSection -- 1844
	end -- 1844
	return table.concat(sections, "\n\n") -- 1846
end -- 1846
function buildSkillsSection(shared) -- 1849
	local ____opt_32 = shared.skills -- 1849
	if not (____opt_32 and ____opt_32.loader) then -- 1849
		return "" -- 1851
	end -- 1851
	return shared.skills.loader:buildSkillsPromptSection() -- 1853
end -- 1853
function buildXmlDecisionInstruction(shared, feedback) -- 1965
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1966
end -- 1966
function emitAgentTaskFinishEvent(shared, success, message) -- 3001
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3002
	emitAgentEvent(shared, { -- 3008
		type = "task_finished", -- 3009
		sessionId = shared.sessionId, -- 3010
		taskId = shared.taskId, -- 3011
		success = result.success, -- 3012
		message = result.message, -- 3013
		steps = result.steps -- 3014
	}) -- 3014
	return result -- 3016
end -- 3016
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
	__TS__ArraySort(result) -- 321
	return result -- 323
end -- 311
function SkillsLoader.prototype.getSkill(self, name) -- 326
	if not self.loaded then -- 326
		self:load() -- 328
	end -- 328
	local ____opt_0 = self.skills:get(name) -- 328
	return ____opt_0 and ____opt_0.skill -- 331
end -- 326
function SkillsLoader.prototype.getAlwaysSkills(self) -- 334
	local all = self:getAllSkills() -- 335
	return __TS__ArrayFilter( -- 336
		all, -- 336
		function(____, skill) return skill.always == true end -- 336
	) -- 336
end -- 334
function SkillsLoader.prototype.getSummarySkills(self) -- 339
	local all = self:getAllSkills() -- 340
	return __TS__ArrayFilter( -- 341
		all, -- 341
		function(____, skill) return skill.always ~= true end -- 341
	) -- 341
end -- 339
function SkillsLoader.prototype.buildLevel1Summary(self) -- 344
	local skills = self:getSummarySkills() -- 345
	if #skills == 0 then -- 345
		return "" -- 348
	end -- 348
	local parts = {} -- 351
	for ____, skill in ipairs(skills) do -- 353
		local skillXML = "<skill>\n" -- 354
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 355
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 356
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 357
		skillXML = skillXML .. "</skill>" -- 358
		parts[#parts + 1] = skillXML -- 359
	end -- 359
	return table.concat(parts, "\n\n") -- 362
end -- 344
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 365
	local skills = self:getAlwaysSkills() -- 366
	if #skills == 0 then -- 366
		return "" -- 369
	end -- 369
	local parts = {} -- 372
	for ____, skill in ipairs(skills) do -- 374
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 375
		if skill.description ~= nil then -- 375
			parts[#parts + 1] = skill.description .. "\n" -- 377
		end -- 377
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 377
			parts[#parts + 1] = "\n" .. skill.body -- 380
		end -- 380
		parts[#parts + 1] = "" -- 382
	end -- 382
	return table.concat(parts, "\n") -- 385
end -- 365
function SkillsLoader.prototype.loadSkillContent(self, name) -- 388
	local skill = self:getSkill(name) -- 389
	if not skill then -- 389
		return nil -- 391
	end -- 391
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 391
		return skill.body -- 395
	end -- 395
	local content = Content:load(skill.location) -- 398
	if not content then -- 398
		return nil -- 400
	end -- 400
	local parsed = parseYAMLFrontmatter(content) -- 403
	return parsed.body or nil -- 404
end -- 388
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 407
	if not self.loaded then -- 407
		self:load() -- 409
	end -- 409
	local sections = {} -- 412
	local activeContent = self:buildActiveSkillsContent() -- 414
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 415
	local summary = self:buildLevel1Summary() -- 417
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 418
	return table.concat(sections, "\n\n---\n\n")
end -- 407
function SkillsLoader.prototype.escapeXML(self, text) -- 423
	return escapeXMLText(text) -- 424
end -- 423
function SkillsLoader.prototype.reload(self) -- 427
	self.loaded = false -- 428
	self:load() -- 429
end -- 427
function SkillsLoader.prototype.getSkillCount(self) -- 432
	if not self.loaded then -- 432
		self:load() -- 434
	end -- 434
	return self.skills.size -- 436
end -- 432
local function createSkillsLoader(config) -- 440
	return __TS__New(SkillsLoader, config) -- 441
end -- 440
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 487
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 610
local HISTORY_READ_FILE_MAX_LINES = 300 -- 611
local READ_FILE_DEFAULT_LIMIT = 300 -- 612
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 613
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 614
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 615
SEARCH_DORA_API_LIMIT_MAX = 20 -- 616
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 617
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 618
local SEARCH_PREVIEW_CONTEXT = 80 -- 619
local function emitAgentStartEvent(shared, action) -- 676
	emitAgentEvent(shared, { -- 677
		type = "tool_started", -- 678
		sessionId = shared.sessionId, -- 679
		taskId = shared.taskId, -- 680
		step = action.step, -- 681
		tool = action.tool -- 682
	}) -- 682
end -- 676
local function emitAgentFinishEvent(shared, action) -- 686
	emitAgentEvent(shared, { -- 687
		type = "tool_finished", -- 688
		sessionId = shared.sessionId, -- 689
		taskId = shared.taskId, -- 690
		step = action.step, -- 691
		tool = action.tool, -- 692
		result = action.result or ({}) -- 693
	}) -- 693
end -- 686
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 697
	emitAgentEvent(shared, { -- 698
		type = "assistant_message_updated", -- 699
		sessionId = shared.sessionId, -- 700
		taskId = shared.taskId, -- 701
		step = shared.step + 1, -- 702
		content = content, -- 703
		reasoningContent = reasoningContent -- 704
	}) -- 704
end -- 697
local function getMemoryCompressionStartReason(shared) -- 708
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 709
end -- 708
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 714
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 715
end -- 714
local function getMemoryCompressionFailureReason(shared, ____error) -- 720
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 721
end -- 720
local function summarizeHistoryEntryPreview(text, maxChars) -- 726
	if maxChars == nil then -- 726
		maxChars = 180 -- 726
	end -- 726
	local trimmed = __TS__StringTrim(text) -- 727
	if trimmed == "" then -- 727
		return "" -- 728
	end -- 728
	return truncateText(trimmed, maxChars) -- 729
end -- 726
local function getCancelledReason(shared) -- 732
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 732
		return shared.stopToken.reason -- 733
	end -- 733
	return shared.useChineseResponse and "已取消" or "cancelled" -- 734
end -- 732
local function getMaxStepsReachedReason(shared) -- 737
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 738
end -- 737
local function getFailureSummaryFallback(shared, ____error) -- 743
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 744
end -- 743
local function finalizeAgentFailure(shared, ____error) -- 749
	if shared.stopToken.stopped then -- 749
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 751
		return emitAgentTaskFinishEvent( -- 752
			shared, -- 752
			false, -- 752
			getCancelledReason(shared) -- 752
		) -- 752
	end -- 752
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 754
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 755
end -- 749
local function getPromptCommand(prompt) -- 758
	local trimmed = __TS__StringTrim(prompt) -- 759
	if trimmed == "/compact" then -- 759
		return "compact" -- 760
	end -- 760
	if trimmed == "/reset" then -- 760
		return "reset" -- 761
	end -- 761
	return nil -- 762
end -- 758
function ____exports.truncateAgentUserPrompt(prompt) -- 765
	if not prompt then -- 765
		return "" -- 766
	end -- 766
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 766
		return prompt -- 767
	end -- 767
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 768
	if offset == nil then -- 768
		return prompt -- 769
	end -- 769
	return string.sub(prompt, 1, offset - 1) -- 770
end -- 765
local function canWriteStepLLMDebug(shared, stepId) -- 773
	if stepId == nil then -- 773
		stepId = shared.step + 1 -- 773
	end -- 773
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 774
end -- 773
local function ensureDirRecursive(dir) -- 781
	if not dir then -- 781
		return false -- 782
	end -- 782
	if Content:exist(dir) then -- 782
		return Content:isdir(dir) -- 783
	end -- 783
	local parent = Path:getPath(dir) -- 784
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 784
		return false -- 786
	end -- 786
	return Content:mkdir(dir) -- 788
end -- 781
local function encodeDebugJSON(value) -- 791
	local text, err = safeJsonEncode(value) -- 792
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 793
end -- 791
local function getStepLLMDebugDir(shared) -- 796
	return Path( -- 797
		shared.workingDir, -- 798
		".agent", -- 799
		tostring(shared.sessionId), -- 800
		tostring(shared.taskId) -- 801
	) -- 801
end -- 796
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 805
	return Path( -- 806
		getStepLLMDebugDir(shared), -- 806
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 806
	) -- 806
end -- 805
local function getLatestStepLLMDebugSeq(shared, stepId) -- 809
	if not canWriteStepLLMDebug(shared, stepId) then -- 809
		return 0 -- 810
	end -- 810
	local dir = getStepLLMDebugDir(shared) -- 811
	if not Content:exist(dir) or not Content:isdir(dir) then -- 811
		return 0 -- 812
	end -- 812
	local latest = 0 -- 813
	for ____, file in ipairs(Content:getFiles(dir)) do -- 814
		do -- 814
			local name = Path:getFilename(file) -- 815
			local seqText = string.match( -- 816
				name, -- 816
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 816
			) -- 816
			if seqText ~= nil then -- 816
				latest = math.max( -- 818
					latest, -- 818
					tonumber(seqText) -- 818
				) -- 818
				goto __continue115 -- 819
			end -- 819
			local legacyMatch = string.match( -- 821
				name, -- 821
				("^" .. tostring(stepId)) .. "_in%.md$" -- 821
			) -- 821
			if legacyMatch ~= nil then -- 821
				latest = math.max(latest, 1) -- 823
			end -- 823
		end -- 823
		::__continue115:: -- 823
	end -- 823
	return latest -- 826
end -- 809
local function writeStepLLMDebugFile(path, content) -- 829
	if not Content:save(path, content) then -- 829
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 831
		return false -- 832
	end -- 832
	return true -- 834
end -- 829
local function createStepLLMDebugPair(shared, stepId, inContent) -- 837
	if not canWriteStepLLMDebug(shared, stepId) then -- 837
		return 0 -- 838
	end -- 838
	local dir = getStepLLMDebugDir(shared) -- 839
	if not ensureDirRecursive(dir) then -- 839
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 841
		return 0 -- 842
	end -- 842
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 844
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 845
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 846
	if not writeStepLLMDebugFile(inPath, inContent) then -- 846
		return 0 -- 848
	end -- 848
	writeStepLLMDebugFile(outPath, "") -- 850
	return seq -- 851
end -- 837
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 854
	if not canWriteStepLLMDebug(shared, stepId) then -- 854
		return -- 855
	end -- 855
	local dir = getStepLLMDebugDir(shared) -- 856
	if not ensureDirRecursive(dir) then -- 856
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 858
		return -- 859
	end -- 859
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 861
	if latestSeq <= 0 then -- 861
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 863
		writeStepLLMDebugFile(outPath, content) -- 864
		return -- 865
	end -- 865
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 867
	writeStepLLMDebugFile(outPath, content) -- 868
end -- 854
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 871
	if not canWriteStepLLMDebug(shared, stepId) then -- 871
		return -- 872
	end -- 872
	local sections = { -- 873
		"# LLM Input", -- 874
		"session_id: " .. tostring(shared.sessionId), -- 875
		"task_id: " .. tostring(shared.taskId), -- 876
		"step_id: " .. tostring(stepId), -- 877
		"phase: " .. phase, -- 878
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 879
		"## Options", -- 880
		"```json", -- 881
		encodeDebugJSON(options), -- 882
		"```" -- 883
	} -- 883
	do -- 883
		local i = 0 -- 885
		while i < #messages do -- 885
			local message = messages[i + 1] -- 886
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 887
			sections[#sections + 1] = encodeDebugJSON(message) -- 888
			i = i + 1 -- 885
		end -- 885
	end -- 885
	createStepLLMDebugPair( -- 890
		shared, -- 890
		stepId, -- 890
		table.concat(sections, "\n") -- 890
	) -- 890
end -- 871
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 893
	if not canWriteStepLLMDebug(shared, stepId) then -- 893
		return -- 894
	end -- 894
	local ____array_2 = __TS__SparseArrayNew( -- 894
		"# LLM Output", -- 896
		"session_id: " .. tostring(shared.sessionId), -- 897
		"task_id: " .. tostring(shared.taskId), -- 898
		"step_id: " .. tostring(stepId), -- 899
		"phase: " .. phase, -- 900
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 901
		table.unpack(meta and ({ -- 902
			"## Meta", -- 902
			"```json", -- 902
			encodeDebugJSON(meta), -- 902
			"```" -- 902
		}) or ({})) -- 902
	) -- 902
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 902
	local sections = {__TS__SparseArraySpread(____array_2)} -- 895
	updateLatestStepLLMDebugOutput( -- 906
		shared, -- 906
		stepId, -- 906
		table.concat(sections, "\n") -- 906
	) -- 906
end -- 893
local function toJson(value) -- 909
	local text, err = safeJsonEncode(value) -- 910
	if text ~= nil then -- 910
		return text -- 911
	end -- 911
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 912
end -- 909
local function utf8TakeHead(text, maxChars) -- 922
	if maxChars <= 0 or text == "" then -- 922
		return "" -- 923
	end -- 923
	local nextPos = utf8.offset(text, maxChars + 1) -- 924
	if nextPos == nil then -- 924
		return text -- 925
	end -- 925
	return string.sub(text, 1, nextPos - 1) -- 926
end -- 922
local function limitReadContentForHistory(content, tool) -- 943
	local lines = __TS__StringSplit(content, "\n") -- 944
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 945
	local limitedByLines = overLineLimit and table.concat( -- 946
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 947
		"\n" -- 947
	) or content -- 947
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 947
		return content -- 950
	end -- 950
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 952
	local reasons = {} -- 955
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 955
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 956
	end -- 956
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 956
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 957
	end -- 957
	local hint = "Narrow the requested line range." -- 958
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 959
end -- 943
local function summarizeEditTextParamForHistory(value, key) -- 962
	if type(value) ~= "string" then -- 962
		return nil -- 963
	end -- 963
	local text = value -- 964
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 965
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 966
end -- 962
local function sanitizeReadResultForHistory(tool, result) -- 974
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 974
		return result -- 976
	end -- 976
	local clone = {} -- 978
	for key in pairs(result) do -- 979
		clone[key] = result[key] -- 980
	end -- 980
	clone.content = limitReadContentForHistory(result.content, tool) -- 982
	return clone -- 983
end -- 974
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 986
	local shown = math.min(#items, maxItems) -- 990
	local out = {} -- 991
	do -- 991
		local i = 0 -- 992
		while i < shown do -- 992
			local row = items[i + 1] -- 993
			out[#out + 1] = { -- 994
				file = row.file, -- 995
				line = row.line, -- 996
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 997
			} -- 997
			i = i + 1 -- 992
		end -- 992
	end -- 992
	return out -- 1002
end -- 986
local function sanitizeSearchResultForHistory(tool, result) -- 1005
	if result.success ~= true or not isArray(result.results) then -- 1005
		return result -- 1009
	end -- 1009
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1009
		return result -- 1010
	end -- 1010
	local clone = {} -- 1011
	for key in pairs(result) do -- 1012
		clone[key] = result[key] -- 1013
	end -- 1013
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1015
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1016
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1016
		local grouped = result.groupedResults -- 1021
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1022
		local sanitizedGroups = {} -- 1023
		do -- 1023
			local i = 0 -- 1024
			while i < shown do -- 1024
				local row = grouped[i + 1] -- 1025
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1026
					file = row.file, -- 1027
					totalMatches = row.totalMatches, -- 1028
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1029
				} -- 1029
				i = i + 1 -- 1024
			end -- 1024
		end -- 1024
		clone.groupedResults = sanitizedGroups -- 1034
	end -- 1034
	return clone -- 1036
end -- 1005
local function sanitizeListFilesResultForHistory(result) -- 1039
	if result.success ~= true or not isArray(result.files) then -- 1039
		return result -- 1040
	end -- 1040
	local clone = {} -- 1041
	for key in pairs(result) do -- 1042
		clone[key] = result[key] -- 1043
	end -- 1043
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1045
	return clone -- 1046
end -- 1039
local function sanitizeActionParamsForHistory(tool, params) -- 1049
	if tool ~= "edit_file" then -- 1049
		return params -- 1050
	end -- 1050
	local clone = {} -- 1051
	for key in pairs(params) do -- 1052
		if key == "old_str" then -- 1052
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1054
		elseif key == "new_str" then -- 1054
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1056
		else -- 1056
			clone[key] = params[key] -- 1058
		end -- 1058
	end -- 1058
	return clone -- 1061
end -- 1049
local function isToolAllowedForRole(role, tool) -- 1094
	return __TS__ArrayIndexOf( -- 1095
		getAllowedToolsForRole(role), -- 1095
		tool -- 1095
	) >= 0 -- 1095
end -- 1094
local function maybeCompressHistory(shared) -- 1098
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1098
		local ____shared_9 = shared -- 1099
		local memory = ____shared_9.memory -- 1099
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1100
		local changed = false -- 1101
		do -- 1101
			local round = 0 -- 1102
			while round < maxRounds do -- 1102
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1103
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1107
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 1107
					if changed then -- 1107
						persistHistoryState(shared) -- 1116
					end -- 1116
					return ____awaiter_resolve(nil) -- 1116
				end -- 1116
				local compressionRound = round + 1 -- 1120
				shared.step = shared.step + 1 -- 1121
				local stepId = shared.step -- 1122
				local pendingMessages = #shared.messages -- 1123
				emitAgentEvent( -- 1124
					shared, -- 1124
					{ -- 1124
						type = "memory_compression_started", -- 1125
						sessionId = shared.sessionId, -- 1126
						taskId = shared.taskId, -- 1127
						step = stepId, -- 1128
						tool = "compress_memory", -- 1129
						reason = getMemoryCompressionStartReason(shared), -- 1130
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1131
					} -- 1131
				) -- 1131
				local result = __TS__Await(memory.compressor:compress( -- 1137
					shared.messages, -- 1138
					shared.llmOptions, -- 1139
					shared.llmMaxTry, -- 1140
					shared.decisionMode, -- 1141
					{ -- 1142
						onInput = function(____, phase, messages, options) -- 1143
							saveStepLLMDebugInput( -- 1144
								shared, -- 1144
								stepId, -- 1144
								phase, -- 1144
								messages, -- 1144
								options -- 1144
							) -- 1144
						end, -- 1143
						onOutput = function(____, phase, text, meta) -- 1146
							saveStepLLMDebugOutput( -- 1147
								shared, -- 1147
								stepId, -- 1147
								phase, -- 1147
								text, -- 1147
								meta -- 1147
							) -- 1147
						end -- 1146
					}, -- 1146
					"default", -- 1150
					systemPrompt, -- 1151
					toolDefinitions -- 1152
				)) -- 1152
				if not (result and result.success and result.compressedCount > 0) then -- 1152
					emitAgentEvent( -- 1155
						shared, -- 1155
						{ -- 1155
							type = "memory_compression_finished", -- 1156
							sessionId = shared.sessionId, -- 1157
							taskId = shared.taskId, -- 1158
							step = stepId, -- 1159
							tool = "compress_memory", -- 1160
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1161
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1165
						} -- 1165
					) -- 1165
					if changed then -- 1165
						persistHistoryState(shared) -- 1173
					end -- 1173
					return ____awaiter_resolve(nil) -- 1173
				end -- 1173
				emitAgentEvent( -- 1177
					shared, -- 1177
					{ -- 1177
						type = "memory_compression_finished", -- 1178
						sessionId = shared.sessionId, -- 1179
						taskId = shared.taskId, -- 1180
						step = stepId, -- 1181
						tool = "compress_memory", -- 1182
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1183
						result = { -- 1184
							success = true, -- 1185
							round = compressionRound, -- 1186
							compressedCount = result.compressedCount, -- 1187
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1188
						} -- 1188
					} -- 1188
				) -- 1188
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1191
				changed = true -- 1192
				Log( -- 1193
					"Info", -- 1193
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1193
				) -- 1193
				round = round + 1 -- 1102
			end -- 1102
		end -- 1102
		if changed then -- 1102
			persistHistoryState(shared) -- 1196
		end -- 1196
	end) -- 1196
end -- 1098
local function compactAllHistory(shared) -- 1200
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1200
		local ____shared_16 = shared -- 1201
		local memory = ____shared_16.memory -- 1201
		local rounds = 0 -- 1202
		local totalCompressed = 0 -- 1203
		while #shared.messages > 0 do -- 1203
			if shared.stopToken.stopped then -- 1203
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1206
				return ____awaiter_resolve( -- 1206
					nil, -- 1206
					emitAgentTaskFinishEvent( -- 1207
						shared, -- 1207
						false, -- 1207
						getCancelledReason(shared) -- 1207
					) -- 1207
				) -- 1207
			end -- 1207
			rounds = rounds + 1 -- 1209
			shared.step = shared.step + 1 -- 1210
			local stepId = shared.step -- 1211
			local pendingMessages = #shared.messages -- 1212
			emitAgentEvent( -- 1213
				shared, -- 1213
				{ -- 1213
					type = "memory_compression_started", -- 1214
					sessionId = shared.sessionId, -- 1215
					taskId = shared.taskId, -- 1216
					step = stepId, -- 1217
					tool = "compress_memory", -- 1218
					reason = getMemoryCompressionStartReason(shared), -- 1219
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1220
				} -- 1220
			) -- 1220
			local result = __TS__Await(memory.compressor:compress( -- 1227
				shared.messages, -- 1228
				shared.llmOptions, -- 1229
				shared.llmMaxTry, -- 1230
				shared.decisionMode, -- 1231
				{ -- 1232
					onInput = function(____, phase, messages, options) -- 1233
						saveStepLLMDebugInput( -- 1234
							shared, -- 1234
							stepId, -- 1234
							phase, -- 1234
							messages, -- 1234
							options -- 1234
						) -- 1234
					end, -- 1233
					onOutput = function(____, phase, text, meta) -- 1236
						saveStepLLMDebugOutput( -- 1237
							shared, -- 1237
							stepId, -- 1237
							phase, -- 1237
							text, -- 1237
							meta -- 1237
						) -- 1237
					end -- 1236
				}, -- 1236
				"budget_max" -- 1240
			)) -- 1240
			if not (result and result.success and result.compressedCount > 0) then -- 1240
				emitAgentEvent( -- 1243
					shared, -- 1243
					{ -- 1243
						type = "memory_compression_finished", -- 1244
						sessionId = shared.sessionId, -- 1245
						taskId = shared.taskId, -- 1246
						step = stepId, -- 1247
						tool = "compress_memory", -- 1248
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1249
						result = { -- 1253
							success = false, -- 1254
							rounds = rounds, -- 1255
							error = result and result.error or "compression returned no changes", -- 1256
							compressedCount = result and result.compressedCount or 0, -- 1257
							fullCompaction = true -- 1258
						} -- 1258
					} -- 1258
				) -- 1258
				return ____awaiter_resolve( -- 1258
					nil, -- 1258
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1261
				) -- 1261
			end -- 1261
			emitAgentEvent( -- 1266
				shared, -- 1266
				{ -- 1266
					type = "memory_compression_finished", -- 1267
					sessionId = shared.sessionId, -- 1268
					taskId = shared.taskId, -- 1269
					step = stepId, -- 1270
					tool = "compress_memory", -- 1271
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1272
					result = { -- 1273
						success = true, -- 1274
						round = rounds, -- 1275
						compressedCount = result.compressedCount, -- 1276
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1277
						fullCompaction = true -- 1278
					} -- 1278
				} -- 1278
			) -- 1278
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1281
			totalCompressed = totalCompressed + result.compressedCount -- 1282
			persistHistoryState(shared) -- 1283
			Log( -- 1284
				"Info", -- 1284
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1284
			) -- 1284
		end -- 1284
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1286
		return ____awaiter_resolve( -- 1286
			nil, -- 1286
			emitAgentTaskFinishEvent( -- 1287
				shared, -- 1288
				true, -- 1289
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1290
			) -- 1290
		) -- 1290
	end) -- 1290
end -- 1200
local function resetSessionHistory(shared) -- 1296
	shared.messages = {} -- 1297
	persistHistoryState(shared) -- 1298
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1299
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1300
end -- 1296
local function isKnownToolName(name) -- 1309
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "spawn_sub_agent" or name == "finish" -- 1310
end -- 1309
local function getFinishMessage(params, fallback) -- 1321
	if fallback == nil then -- 1321
		fallback = "" -- 1321
	end -- 1321
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1321
		return __TS__StringTrim(params.message) -- 1323
	end -- 1323
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1323
		return __TS__StringTrim(params.response) -- 1326
	end -- 1326
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1326
		return __TS__StringTrim(params.summary) -- 1329
	end -- 1329
	return __TS__StringTrim(fallback) -- 1331
end -- 1321
local function maybeProcessPendingMemoryMerge(shared) -- 1338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1338
		if shared.role ~= "main" then -- 1338
			return ____awaiter_resolve(nil) -- 1338
		end -- 1338
		local queue = shared.memory.compressor:getMergeQueue() -- 1342
		while true do -- 1342
			do -- 1342
				local job = queue:readOldestJob() -- 1344
				if not job then -- 1344
					return ____awaiter_resolve(nil) -- 1344
				end -- 1344
				shared.step = shared.step + 1 -- 1348
				local stepId = shared.step -- 1349
				emitAgentEvent(shared, { -- 1350
					type = "memory_merge_started", -- 1351
					sessionId = shared.sessionId, -- 1352
					taskId = shared.taskId, -- 1353
					step = stepId, -- 1354
					jobId = job.jobId, -- 1355
					sourceAgentId = job.sourceAgentId, -- 1356
					sourceTitle = job.sourceTitle -- 1357
				}) -- 1357
				Log("Info", (("[CodingAgent] processing memory merge job=" .. job.jobId) .. " source=") .. job.sourceAgentId) -- 1359
				local result = __TS__Await(shared.memory.compressor:mergeSubAgentMemory( -- 1360
					job, -- 1361
					shared.llmOptions, -- 1362
					shared.llmMaxTry, -- 1363
					shared.decisionMode, -- 1364
					{ -- 1365
						onInput = function(____, phase, messages, options) -- 1366
							saveStepLLMDebugInput( -- 1367
								shared, -- 1367
								stepId, -- 1367
								phase .. "_merge", -- 1367
								messages, -- 1367
								options -- 1367
							) -- 1367
						end, -- 1366
						onOutput = function(____, phase, text, meta) -- 1369
							saveStepLLMDebugOutput( -- 1370
								shared, -- 1370
								stepId, -- 1370
								phase .. "_merge", -- 1370
								text, -- 1370
								meta -- 1370
							) -- 1370
						end -- 1369
					} -- 1369
				)) -- 1369
				if result.success then -- 1369
					queue:deleteJob(job.path) -- 1375
					emitAgentEvent(shared, { -- 1376
						type = "memory_merge_finished", -- 1377
						sessionId = shared.sessionId, -- 1378
						taskId = shared.taskId, -- 1379
						step = stepId, -- 1380
						jobId = job.jobId, -- 1381
						sourceAgentId = job.sourceAgentId, -- 1382
						sourceTitle = job.sourceTitle, -- 1383
						success = true, -- 1384
						message = shared.useChineseResponse and ("已合并来自`" .. job.sourceTitle) .. "`的子代理记忆。" or ("Merged sub-agent memory from `" .. job.sourceTitle) .. "`.", -- 1385
						attempts = job.attempts -- 1388
					}) -- 1388
					Log("Info", "[CodingAgent] memory merge job applied=" .. job.jobId) -- 1390
					goto __continue207 -- 1391
				end -- 1391
				queue:updateJobFailure(job, result.error or "memory merge failed") -- 1393
				local nextAttempts = (job.attempts or 0) + 1 -- 1394
				emitAgentEvent(shared, { -- 1395
					type = "memory_merge_finished", -- 1396
					sessionId = shared.sessionId, -- 1397
					taskId = shared.taskId, -- 1398
					step = stepId, -- 1399
					jobId = job.jobId, -- 1400
					sourceAgentId = job.sourceAgentId, -- 1401
					sourceTitle = job.sourceTitle, -- 1402
					success = false, -- 1403
					message = result.error or "memory merge failed", -- 1404
					attempts = nextAttempts -- 1405
				}) -- 1405
				Log("Warn", (("[CodingAgent] memory merge job failed=" .. job.jobId) .. " error=") .. (result.error or "unknown")) -- 1407
				if nextAttempts >= shared.llmMaxTry then -- 1407
					error( -- 1409
						__TS__New(Error, shared.useChineseResponse and (("记忆合并任务多次失败，已中止当前会话。来源：" .. job.sourceTitle) .. "，错误：") .. (result.error or "unknown") or (("Memory merge job exceeded retry limit and aborted the current session. Source: " .. job.sourceTitle) .. ". Error: ") .. (result.error or "unknown")), -- 1409
						0 -- 1409
					) -- 1409
				end -- 1409
				goto __continue207 -- 1413
			end -- 1413
			::__continue207:: -- 1413
		end -- 1413
	end) -- 1413
end -- 1338
local function appendConversationMessage(shared, message) -- 1432
	local ____shared_messages_25 = shared.messages -- 1432
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1433
		{}, -- 1433
		message, -- 1434
		{ -- 1433
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1435
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1436
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1437
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1438
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1439
		} -- 1439
	) -- 1439
end -- 1432
local function ensureToolCallId(toolCallId) -- 1443
	if toolCallId and toolCallId ~= "" then -- 1443
		return toolCallId -- 1444
	end -- 1444
	return createLocalToolCallId() -- 1445
end -- 1443
local function appendToolResultMessage(shared, action) -- 1448
	appendConversationMessage( -- 1449
		shared, -- 1449
		{ -- 1449
			role = "tool", -- 1450
			tool_call_id = action.toolCallId, -- 1451
			name = action.tool, -- 1452
			content = action.result and toJson(action.result) or "" -- 1453
		} -- 1453
	) -- 1453
end -- 1448
local function parseXMLToolCallObjectFromText(text) -- 1457
	local children = parseXMLObjectFromText(text, "tool_call") -- 1458
	if not children.success then -- 1458
		return children -- 1459
	end -- 1459
	local rawObj = children.obj -- 1460
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1461
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1462
	if not params.success then -- 1462
		return {success = false, message = params.message} -- 1466
	end -- 1466
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1468
end -- 1457
local function llm(shared, messages, phase) -- 1487
	if phase == nil then -- 1487
		phase = "decision_xml" -- 1490
	end -- 1490
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1490
		local stepId = shared.step + 1 -- 1492
		saveStepLLMDebugInput( -- 1493
			shared, -- 1493
			stepId, -- 1493
			phase, -- 1493
			messages, -- 1493
			shared.llmOptions -- 1493
		) -- 1493
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1494
		if res.success then -- 1494
			local ____opt_30 = res.response.choices -- 1494
			local ____opt_28 = ____opt_30 and ____opt_30[1] -- 1494
			local ____opt_26 = ____opt_28 and ____opt_28.message -- 1494
			local text = ____opt_26 and ____opt_26.content -- 1496
			if text then -- 1496
				saveStepLLMDebugOutput( -- 1498
					shared, -- 1498
					stepId, -- 1498
					phase, -- 1498
					text, -- 1498
					{success = true} -- 1498
				) -- 1498
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 1498
			else -- 1498
				saveStepLLMDebugOutput( -- 1501
					shared, -- 1501
					stepId, -- 1501
					phase, -- 1501
					"empty LLM response", -- 1501
					{success = false} -- 1501
				) -- 1501
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1501
			end -- 1501
		else -- 1501
			saveStepLLMDebugOutput( -- 1505
				shared, -- 1505
				stepId, -- 1505
				phase, -- 1505
				res.raw or res.message, -- 1505
				{success = false} -- 1505
			) -- 1505
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1505
		end -- 1505
	end) -- 1505
end -- 1487
local function parseDecisionObject(rawObj) -- 1522
	if type(rawObj.tool) ~= "string" then -- 1522
		return {success = false, message = "missing tool"} -- 1523
	end -- 1523
	local tool = rawObj.tool -- 1524
	if not isKnownToolName(tool) then -- 1524
		return {success = false, message = "unknown tool: " .. tool} -- 1526
	end -- 1526
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1528
	if tool ~= "finish" and (not reason or reason == "") then -- 1528
		return {success = false, message = tool .. " requires top-level reason"} -- 1532
	end -- 1532
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1534
	return {success = true, tool = tool, params = params, reason = reason} -- 1535
end -- 1522
local function parseDecisionToolCall(functionName, rawObj) -- 1543
	if not isKnownToolName(functionName) then -- 1543
		return {success = false, message = "unknown tool: " .. functionName} -- 1545
	end -- 1545
	if rawObj == nil or rawObj == nil then -- 1545
		return {success = true, tool = functionName, params = {}} -- 1548
	end -- 1548
	if not isRecord(rawObj) then -- 1548
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1551
	end -- 1551
	return {success = true, tool = functionName, params = rawObj} -- 1553
end -- 1543
local function getDecisionPath(params) -- 1560
	if type(params.path) == "string" then -- 1560
		return __TS__StringTrim(params.path) -- 1561
	end -- 1561
	if type(params.target_file) == "string" then -- 1561
		return __TS__StringTrim(params.target_file) -- 1562
	end -- 1562
	return "" -- 1563
end -- 1560
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1566
	local num = __TS__Number(value) -- 1567
	if not __TS__NumberIsFinite(num) then -- 1567
		num = fallback -- 1568
	end -- 1568
	num = math.floor(num) -- 1569
	if num < minValue then -- 1569
		num = minValue -- 1570
	end -- 1570
	if maxValue ~= nil and num > maxValue then -- 1570
		num = maxValue -- 1571
	end -- 1571
	return num -- 1572
end -- 1566
local function parseReadLineParam(value, fallback, paramName) -- 1575
	local num = __TS__Number(value) -- 1580
	if not __TS__NumberIsFinite(num) then -- 1580
		num = fallback -- 1581
	end -- 1581
	num = math.floor(num) -- 1582
	if num == 0 then -- 1582
		return {success = false, message = paramName .. " cannot be 0"} -- 1584
	end -- 1584
	return {success = true, value = num} -- 1586
end -- 1575
local function validateDecision(tool, params) -- 1589
	if tool == "finish" then -- 1589
		local message = getFinishMessage(params) -- 1594
		if message == "" then -- 1594
			return {success = false, message = "finish requires params.message"} -- 1595
		end -- 1595
		params.message = message -- 1596
		return {success = true, params = params} -- 1597
	end -- 1597
	if tool == "read_file" then -- 1597
		local path = getDecisionPath(params) -- 1601
		if path == "" then -- 1601
			return {success = false, message = "read_file requires path"} -- 1602
		end -- 1602
		params.path = path -- 1603
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1604
		if not startLineRes.success then -- 1604
			return startLineRes -- 1605
		end -- 1605
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1606
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1607
		if not endLineRes.success then -- 1607
			return endLineRes -- 1608
		end -- 1608
		params.startLine = startLineRes.value -- 1609
		params.endLine = endLineRes.value -- 1610
		return {success = true, params = params} -- 1611
	end -- 1611
	if tool == "edit_file" then -- 1611
		local path = getDecisionPath(params) -- 1615
		if path == "" then -- 1615
			return {success = false, message = "edit_file requires path"} -- 1616
		end -- 1616
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1617
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1618
		params.path = path -- 1619
		params.old_str = oldStr -- 1620
		params.new_str = newStr -- 1621
		return {success = true, params = params} -- 1622
	end -- 1622
	if tool == "delete_file" then -- 1622
		local targetFile = getDecisionPath(params) -- 1626
		if targetFile == "" then -- 1626
			return {success = false, message = "delete_file requires target_file"} -- 1627
		end -- 1627
		params.target_file = targetFile -- 1628
		return {success = true, params = params} -- 1629
	end -- 1629
	if tool == "grep_files" then -- 1629
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1633
		if pattern == "" then -- 1633
			return {success = false, message = "grep_files requires pattern"} -- 1634
		end -- 1634
		params.pattern = pattern -- 1635
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1636
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1637
		return {success = true, params = params} -- 1638
	end -- 1638
	if tool == "search_dora_api" then -- 1638
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1642
		if pattern == "" then -- 1642
			return {success = false, message = "search_dora_api requires pattern"} -- 1643
		end -- 1643
		params.pattern = pattern -- 1644
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1645
		return {success = true, params = params} -- 1646
	end -- 1646
	if tool == "glob_files" then -- 1646
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1650
		return {success = true, params = params} -- 1651
	end -- 1651
	if tool == "build" then -- 1651
		local path = getDecisionPath(params) -- 1655
		if path ~= "" then -- 1655
			params.path = path -- 1657
		end -- 1657
		return {success = true, params = params} -- 1659
	end -- 1659
	if tool == "spawn_sub_agent" then -- 1659
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1663
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1664
		if prompt == "" then -- 1664
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1665
		end -- 1665
		if title == "" then -- 1665
			return {success = false, message = "spawn_sub_agent requires title"} -- 1666
		end -- 1666
		params.prompt = prompt -- 1667
		params.title = title -- 1668
		if type(params.expectedOutput) == "string" then -- 1668
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1670
		end -- 1670
		if isArray(params.filesHint) then -- 1670
			params.filesHint = __TS__ArrayMap( -- 1673
				__TS__ArrayFilter( -- 1673
					params.filesHint, -- 1673
					function(____, item) return type(item) == "string" end -- 1674
				), -- 1674
				function(____, item) return sanitizeUTF8(item) end -- 1675
			) -- 1675
		end -- 1675
		return {success = true, params = params} -- 1677
	end -- 1677
	return {success = true, params = params} -- 1680
end -- 1589
local function createFunctionToolSchema(name, description, properties, required) -- 1683
	if required == nil then -- 1683
		required = {} -- 1687
	end -- 1687
	local parameters = {type = "object", properties = properties} -- 1689
	if #required > 0 then -- 1689
		parameters.required = required -- 1694
	end -- 1694
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1696
end -- 1683
local function buildDecisionToolSchema(shared) -- 1712
	local allowed = getAllowedToolsForRole(shared.role) -- 1713
	local tools = { -- 1714
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1715
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1725
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1735
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1743
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1747
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1748
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1749
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1750
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1751
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1752
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1753
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1754
		}, {"pattern"}), -- 1754
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1758
		createFunctionToolSchema( -- 1767
			"search_dora_api", -- 1768
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1768
			{ -- 1770
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1771
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1772
				programmingLanguage = {type = "string", enum = { -- 1773
					"ts", -- 1775
					"tsx", -- 1775
					"lua", -- 1775
					"yue", -- 1775
					"teal", -- 1775
					"tl", -- 1775
					"wa" -- 1775
				}, description = "Preferred language variant to search."}, -- 1775
				limit = { -- 1778
					type = "number", -- 1778
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1778
				}, -- 1778
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1779
			}, -- 1779
			{"pattern"} -- 1781
		), -- 1781
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1783
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute concrete work. Use this when the task moves from discussion/search into coding, file editing, file deletion, build verification, documentation writing, or other execution-heavy work. The sub agent has the full execution toolset including edit_file, delete_file, and build.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1790
	} -- 1790
	return __TS__ArrayFilter( -- 1802
		tools, -- 1802
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1802
	) -- 1802
end -- 1712
local function sanitizeMessagesForLLMInput(messages) -- 1856
	local sanitized = {} -- 1857
	local droppedAssistantToolCalls = 0 -- 1858
	local droppedToolResults = 0 -- 1859
	do -- 1859
		local i = 0 -- 1860
		while i < #messages do -- 1860
			do -- 1860
				local message = messages[i + 1] -- 1861
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1861
					local requiredIds = {} -- 1863
					do -- 1863
						local j = 0 -- 1864
						while j < #message.tool_calls do -- 1864
							local toolCall = message.tool_calls[j + 1] -- 1865
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1866
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1866
								requiredIds[#requiredIds + 1] = id -- 1868
							end -- 1868
							j = j + 1 -- 1864
						end -- 1864
					end -- 1864
					if #requiredIds == 0 then -- 1864
						sanitized[#sanitized + 1] = message -- 1872
						goto __continue284 -- 1873
					end -- 1873
					local matchedIds = {} -- 1875
					local matchedTools = {} -- 1876
					local j = i + 1 -- 1877
					while j < #messages do -- 1877
						local toolMessage = messages[j + 1] -- 1879
						if toolMessage.role ~= "tool" then -- 1879
							break -- 1880
						end -- 1880
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1881
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1881
							matchedIds[toolCallId] = true -- 1883
							matchedTools[#matchedTools + 1] = toolMessage -- 1884
						else -- 1884
							droppedToolResults = droppedToolResults + 1 -- 1886
						end -- 1886
						j = j + 1 -- 1888
					end -- 1888
					local complete = true -- 1890
					do -- 1890
						local j = 0 -- 1891
						while j < #requiredIds do -- 1891
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1891
								complete = false -- 1893
								break -- 1894
							end -- 1894
							j = j + 1 -- 1891
						end -- 1891
					end -- 1891
					if complete then -- 1891
						__TS__ArrayPush( -- 1898
							sanitized, -- 1898
							message, -- 1898
							table.unpack(matchedTools) -- 1898
						) -- 1898
					else -- 1898
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1900
						droppedToolResults = droppedToolResults + #matchedTools -- 1901
					end -- 1901
					i = j - 1 -- 1903
					goto __continue284 -- 1904
				end -- 1904
				if message.role == "tool" then -- 1904
					droppedToolResults = droppedToolResults + 1 -- 1907
					goto __continue284 -- 1908
				end -- 1908
				sanitized[#sanitized + 1] = message -- 1910
			end -- 1910
			::__continue284:: -- 1910
			i = i + 1 -- 1860
		end -- 1860
	end -- 1860
	return sanitized -- 1912
end -- 1856
local function getUnconsolidatedMessages(shared) -- 1915
	return sanitizeMessagesForLLMInput(shared.messages) -- 1916
end -- 1915
local function getFinalDecisionTurnPrompt(shared) -- 1919
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1920
end -- 1919
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1925
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1925
		return messages -- 1926
	end -- 1926
	local next = __TS__ArrayMap( -- 1927
		messages, -- 1927
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1927
	) -- 1927
	do -- 1927
		local i = #next - 1 -- 1928
		while i >= 0 do -- 1928
			do -- 1928
				local message = next[i + 1] -- 1929
				if message.role ~= "assistant" and message.role ~= "user" then -- 1929
					goto __continue306 -- 1930
				end -- 1930
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1931
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1932
				return next -- 1935
			end -- 1935
			::__continue306:: -- 1935
			i = i - 1 -- 1928
		end -- 1928
	end -- 1928
	next[#next + 1] = {role = "user", content = prompt} -- 1937
	return next -- 1938
end -- 1925
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1941
	if attempt == nil then -- 1941
		attempt = 1 -- 1941
	end -- 1941
	local messages = { -- 1942
		{ -- 1943
			role = "system", -- 1943
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1943
		}, -- 1943
		table.unpack(getUnconsolidatedMessages(shared)) -- 1944
	} -- 1944
	if shared.step + 1 >= shared.maxSteps then -- 1944
		messages = appendPromptToLatestDecisionMessage( -- 1947
			messages, -- 1947
			getFinalDecisionTurnPrompt(shared) -- 1947
		) -- 1947
	end -- 1947
	if lastError and lastError ~= "" then -- 1947
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1950
		messages[#messages + 1] = { -- 1953
			role = "user", -- 1954
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1955
		} -- 1955
	end -- 1955
	return messages -- 1962
end -- 1941
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1969
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1976
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1977
	local repairPrompt = replacePromptVars( -- 1985
		shared.promptPack.xmlDecisionRepairPrompt, -- 1985
		{ -- 1985
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1986
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1987
			CANDIDATE_SECTION = candidateSection, -- 1988
			LAST_ERROR = lastError, -- 1989
			ATTEMPT = tostring(attempt) -- 1990
		} -- 1990
	) -- 1990
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 1992
end -- 1969
local function tryParseAndValidateDecision(rawText) -- 2004
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2005
	if not parsed.success then -- 2005
		return {success = false, message = parsed.message, raw = rawText} -- 2007
	end -- 2007
	local decision = parseDecisionObject(parsed.obj) -- 2009
	if not decision.success then -- 2009
		return {success = false, message = decision.message, raw = rawText} -- 2011
	end -- 2011
	local validation = validateDecision(decision.tool, decision.params) -- 2013
	if not validation.success then -- 2013
		return {success = false, message = validation.message, raw = rawText} -- 2015
	end -- 2015
	decision.params = validation.params -- 2017
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2018
	return decision -- 2019
end -- 2004
local function normalizeLineEndings(text) -- 2022
	local res = string.gsub(text, "\r\n", "\n") -- 2023
	res = string.gsub(res, "\r", "\n") -- 2024
	return res -- 2025
end -- 2022
local function countOccurrences(text, searchStr) -- 2028
	if searchStr == "" then -- 2028
		return 0 -- 2029
	end -- 2029
	local count = 0 -- 2030
	local pos = 0 -- 2031
	while true do -- 2031
		local idx = (string.find( -- 2033
			text, -- 2033
			searchStr, -- 2033
			math.max(pos + 1, 1), -- 2033
			true -- 2033
		) or 0) - 1 -- 2033
		if idx < 0 then -- 2033
			break -- 2034
		end -- 2034
		count = count + 1 -- 2035
		pos = idx + #searchStr -- 2036
	end -- 2036
	return count -- 2038
end -- 2028
local function replaceFirst(text, oldStr, newStr) -- 2041
	if oldStr == "" then -- 2041
		return text -- 2042
	end -- 2042
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2043
	if idx < 0 then -- 2043
		return text -- 2044
	end -- 2044
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2045
end -- 2041
local function splitLines(text) -- 2048
	return __TS__StringSplit(text, "\n") -- 2049
end -- 2048
local function getLeadingWhitespace(text) -- 2052
	local i = 0 -- 2053
	while i < #text do -- 2053
		local ch = __TS__StringAccess(text, i) -- 2055
		if ch ~= " " and ch ~= "\t" then -- 2055
			break -- 2056
		end -- 2056
		i = i + 1 -- 2057
	end -- 2057
	return __TS__StringSubstring(text, 0, i) -- 2059
end -- 2052
local function getCommonIndentPrefix(lines) -- 2062
	local common -- 2063
	do -- 2063
		local i = 0 -- 2064
		while i < #lines do -- 2064
			do -- 2064
				local line = lines[i + 1] -- 2065
				if __TS__StringTrim(line) == "" then -- 2065
					goto __continue331 -- 2066
				end -- 2066
				local indent = getLeadingWhitespace(line) -- 2067
				if common == nil then -- 2067
					common = indent -- 2069
					goto __continue331 -- 2070
				end -- 2070
				local j = 0 -- 2072
				local maxLen = math.min(#common, #indent) -- 2073
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2073
					j = j + 1 -- 2075
				end -- 2075
				common = __TS__StringSubstring(common, 0, j) -- 2077
				if common == "" then -- 2077
					break -- 2078
				end -- 2078
			end -- 2078
			::__continue331:: -- 2078
			i = i + 1 -- 2064
		end -- 2064
	end -- 2064
	return common or "" -- 2080
end -- 2062
local function removeIndentPrefix(line, indent) -- 2083
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2083
		return __TS__StringSubstring(line, #indent) -- 2085
	end -- 2085
	local lineIndent = getLeadingWhitespace(line) -- 2087
	local j = 0 -- 2088
	local maxLen = math.min(#lineIndent, #indent) -- 2089
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2089
		j = j + 1 -- 2091
	end -- 2091
	return __TS__StringSubstring(line, j) -- 2093
end -- 2083
local function dedentLines(lines) -- 2096
	local indent = getCommonIndentPrefix(lines) -- 2097
	return { -- 2098
		indent = indent, -- 2099
		lines = __TS__ArrayMap( -- 2100
			lines, -- 2100
			function(____, line) return removeIndentPrefix(line, indent) end -- 2100
		) -- 2100
	} -- 2100
end -- 2096
local function joinLines(lines) -- 2104
	return table.concat(lines, "\n") -- 2105
end -- 2104
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2108
	local contentLines = splitLines(content) -- 2113
	local oldLines = splitLines(oldStr) -- 2114
	if #oldLines == 0 then -- 2114
		return {success = false, message = "old_str not found in file"} -- 2116
	end -- 2116
	local dedentedOld = dedentLines(oldLines) -- 2118
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2119
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2120
	local matches = {} -- 2121
	do -- 2121
		local start = 0 -- 2122
		while start <= #contentLines - #oldLines do -- 2122
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2123
			local dedentedCandidate = dedentLines(candidateLines) -- 2124
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2124
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2126
			end -- 2126
			start = start + 1 -- 2122
		end -- 2122
	end -- 2122
	if #matches == 0 then -- 2122
		return {success = false, message = "old_str not found in file"} -- 2134
	end -- 2134
	if #matches > 1 then -- 2134
		return { -- 2137
			success = false, -- 2138
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2139
		} -- 2139
	end -- 2139
	local match = matches[1] -- 2142
	local rebuiltNewLines = __TS__ArrayMap( -- 2143
		dedentedNew.lines, -- 2143
		function(____, line) return line == "" and "" or match.indent .. line end -- 2143
	) -- 2143
	local ____array_36 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2143
	__TS__SparseArrayPush( -- 2143
		____array_36, -- 2143
		table.unpack(rebuiltNewLines) -- 2146
	) -- 2146
	__TS__SparseArrayPush( -- 2146
		____array_36, -- 2146
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2147
	) -- 2147
	local nextLines = {__TS__SparseArraySpread(____array_36)} -- 2144
	return { -- 2149
		success = true, -- 2149
		content = joinLines(nextLines) -- 2149
	} -- 2149
end -- 2108
local MainDecisionAgent = __TS__Class() -- 2152
MainDecisionAgent.name = "MainDecisionAgent" -- 2152
__TS__ClassExtends(MainDecisionAgent, Node) -- 2152
function MainDecisionAgent.prototype.prep(self, shared) -- 2153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2153
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2153
			return ____awaiter_resolve(nil, {shared = shared}) -- 2153
		end -- 2153
		__TS__Await(maybeProcessPendingMemoryMerge(shared)) -- 2158
		__TS__Await(maybeCompressHistory(shared)) -- 2159
		return ____awaiter_resolve(nil, {shared = shared}) -- 2159
	end) -- 2159
end -- 2153
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2164
	if attempt == nil then -- 2164
		attempt = 1 -- 2167
	end -- 2167
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2167
		if shared.stopToken.stopped then -- 2167
			return ____awaiter_resolve( -- 2167
				nil, -- 2167
				{ -- 2171
					success = false, -- 2171
					message = getCancelledReason(shared) -- 2171
				} -- 2171
			) -- 2171
		end -- 2171
		Log( -- 2173
			"Info", -- 2173
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2173
		) -- 2173
		local tools = buildDecisionToolSchema(shared) -- 2174
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2175
		local stepId = shared.step + 1 -- 2176
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2177
		saveStepLLMDebugInput( -- 2181
			shared, -- 2181
			stepId, -- 2181
			"decision_tool_calling", -- 2181
			messages, -- 2181
			llmOptions -- 2181
		) -- 2181
		local lastStreamContent = "" -- 2182
		local lastStreamReasoning = "" -- 2183
		local res = __TS__Await(callLLMStreamAggregated( -- 2184
			messages, -- 2185
			llmOptions, -- 2186
			shared.stopToken, -- 2187
			shared.llmConfig, -- 2188
			function(response) -- 2189
				local ____opt_39 = response.choices -- 2189
				local ____opt_37 = ____opt_39 and ____opt_39[1] -- 2189
				local streamMessage = ____opt_37 and ____opt_37.message -- 2190
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2191
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2194
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2194
					return -- 2198
				end -- 2198
				lastStreamContent = nextContent -- 2200
				lastStreamReasoning = nextReasoning -- 2201
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2202
			end -- 2189
		)) -- 2189
		if shared.stopToken.stopped then -- 2189
			return ____awaiter_resolve( -- 2189
				nil, -- 2189
				{ -- 2206
					success = false, -- 2206
					message = getCancelledReason(shared) -- 2206
				} -- 2206
			) -- 2206
		end -- 2206
		if not res.success then -- 2206
			saveStepLLMDebugOutput( -- 2209
				shared, -- 2209
				stepId, -- 2209
				"decision_tool_calling", -- 2209
				res.raw or res.message, -- 2209
				{success = false} -- 2209
			) -- 2209
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2210
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2210
		end -- 2210
		saveStepLLMDebugOutput( -- 2213
			shared, -- 2213
			stepId, -- 2213
			"decision_tool_calling", -- 2213
			encodeDebugJSON(res.response), -- 2213
			{success = true} -- 2213
		) -- 2213
		local choice = res.response.choices and res.response.choices[1] -- 2214
		local message = choice and choice.message -- 2215
		local toolCalls = message and message.tool_calls -- 2216
		local toolCall = toolCalls and toolCalls[1] -- 2217
		local fn = toolCall and toolCall["function"] -- 2218
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2219
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 2222
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2225
		Log( -- 2228
			"Info", -- 2228
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2228
		) -- 2228
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2228
			if messageContent and messageContent ~= "" then -- 2228
				Log( -- 2231
					"Info", -- 2231
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2231
				) -- 2231
				return ____awaiter_resolve(nil, { -- 2231
					success = true, -- 2233
					tool = "finish", -- 2234
					params = {}, -- 2235
					reason = messageContent, -- 2236
					reasoningContent = reasoningContent, -- 2237
					directSummary = messageContent -- 2238
				}) -- 2238
			end -- 2238
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2241
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2241
		end -- 2241
		local functionName = fn.name -- 2248
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2249
		Log( -- 2250
			"Info", -- 2250
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2250
		) -- 2250
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2251
			local rawObj, err = safeJsonDecode(argsText) -- 2252
			if err ~= nil or rawObj == nil then -- 2252
				return {__error = tostring(err)} -- 2254
			end -- 2254
			return rawObj -- 2256
		end)() -- 2251
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2251
			local err = tostring(rawArgs.__error) -- 2259
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2260
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2260
		end -- 2260
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2267
		if not decision.success then -- 2267
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2269
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2269
		end -- 2269
		local validation = validateDecision(decision.tool, decision.params) -- 2276
		if not validation.success then -- 2276
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2278
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2278
		end -- 2278
		if not isToolAllowedForRole(shared.role, decision.tool) then -- 2278
			return ____awaiter_resolve(nil, {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText}) -- 2278
		end -- 2278
		decision.params = validation.params -- 2292
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2293
		decision.reason = messageContent -- 2294
		decision.reasoningContent = reasoningContent -- 2295
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2296
		return ____awaiter_resolve(nil, decision) -- 2296
	end) -- 2296
end -- 2164
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2300
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2300
		Log( -- 2305
			"Info", -- 2305
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2305
		) -- 2305
		local lastError = initialError -- 2306
		local candidateRaw = "" -- 2307
		do -- 2307
			local attempt = 0 -- 2308
			while attempt < shared.llmMaxTry do -- 2308
				do -- 2308
					Log( -- 2309
						"Info", -- 2309
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2309
					) -- 2309
					local messages = buildXmlRepairMessages( -- 2310
						shared, -- 2311
						originalRaw, -- 2312
						candidateRaw, -- 2313
						lastError, -- 2314
						attempt + 1 -- 2315
					) -- 2315
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2317
					if shared.stopToken.stopped then -- 2317
						return ____awaiter_resolve( -- 2317
							nil, -- 2317
							{ -- 2319
								success = false, -- 2319
								message = getCancelledReason(shared) -- 2319
							} -- 2319
						) -- 2319
					end -- 2319
					if not llmRes.success then -- 2319
						lastError = llmRes.message -- 2322
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2323
						goto __continue368 -- 2324
					end -- 2324
					candidateRaw = llmRes.text -- 2326
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2327
					if decision.success then -- 2327
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2329
						return ____awaiter_resolve(nil, decision) -- 2329
					end -- 2329
					lastError = decision.message -- 2332
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2333
				end -- 2333
				::__continue368:: -- 2333
				attempt = attempt + 1 -- 2308
			end -- 2308
		end -- 2308
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2335
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2335
	end) -- 2335
end -- 2300
function MainDecisionAgent.prototype.exec(self, input) -- 2343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2343
		local shared = input.shared -- 2344
		if shared.stopToken.stopped then -- 2344
			return ____awaiter_resolve( -- 2344
				nil, -- 2344
				{ -- 2346
					success = false, -- 2346
					message = getCancelledReason(shared) -- 2346
				} -- 2346
			) -- 2346
		end -- 2346
		if shared.step >= shared.maxSteps then -- 2346
			Log( -- 2349
				"Warn", -- 2349
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2349
			) -- 2349
			return ____awaiter_resolve( -- 2349
				nil, -- 2349
				{ -- 2350
					success = false, -- 2350
					message = getMaxStepsReachedReason(shared) -- 2350
				} -- 2350
			) -- 2350
		end -- 2350
		if shared.decisionMode == "tool_calling" then -- 2350
			Log( -- 2354
				"Info", -- 2354
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2354
			) -- 2354
			local lastError = "tool calling validation failed" -- 2355
			local lastRaw = "" -- 2356
			do -- 2356
				local attempt = 0 -- 2357
				while attempt < shared.llmMaxTry do -- 2357
					Log( -- 2358
						"Info", -- 2358
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2358
					) -- 2358
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2359
					if shared.stopToken.stopped then -- 2359
						return ____awaiter_resolve( -- 2359
							nil, -- 2359
							{ -- 2366
								success = false, -- 2366
								message = getCancelledReason(shared) -- 2366
							} -- 2366
						) -- 2366
					end -- 2366
					if decision.success then -- 2366
						return ____awaiter_resolve(nil, decision) -- 2366
					end -- 2366
					lastError = decision.message -- 2371
					lastRaw = decision.raw or "" -- 2372
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2373
					attempt = attempt + 1 -- 2357
				end -- 2357
			end -- 2357
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2375
			return ____awaiter_resolve( -- 2375
				nil, -- 2375
				{ -- 2376
					success = false, -- 2376
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2376
				} -- 2376
			) -- 2376
		end -- 2376
		local lastError = "xml validation failed" -- 2379
		local lastRaw = "" -- 2380
		do -- 2380
			local attempt = 0 -- 2381
			while attempt < shared.llmMaxTry do -- 2381
				do -- 2381
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2382
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2390
					if shared.stopToken.stopped then -- 2390
						return ____awaiter_resolve( -- 2390
							nil, -- 2390
							{ -- 2392
								success = false, -- 2392
								message = getCancelledReason(shared) -- 2392
							} -- 2392
						) -- 2392
					end -- 2392
					if not llmRes.success then -- 2392
						lastError = llmRes.message -- 2395
						lastRaw = llmRes.text or "" -- 2396
						goto __continue381 -- 2397
					end -- 2397
					lastRaw = llmRes.text -- 2399
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2400
					if decision.success then -- 2400
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2400
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2403
							return ____awaiter_resolve( -- 2403
								nil, -- 2403
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2404
							) -- 2404
						end -- 2404
						return ____awaiter_resolve(nil, decision) -- 2404
					end -- 2404
					lastError = decision.message -- 2408
					return ____awaiter_resolve( -- 2408
						nil, -- 2408
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2409
					) -- 2409
				end -- 2409
				::__continue381:: -- 2409
				attempt = attempt + 1 -- 2381
			end -- 2381
		end -- 2381
		return ____awaiter_resolve( -- 2381
			nil, -- 2381
			{ -- 2411
				success = false, -- 2411
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2411
			} -- 2411
		) -- 2411
	end) -- 2411
end -- 2343
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2414
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2414
		local result = execRes -- 2415
		if not result.success then -- 2415
			if shared.stopToken.stopped then -- 2415
				shared.error = getCancelledReason(shared) -- 2418
				shared.done = true -- 2419
				return ____awaiter_resolve(nil, "done") -- 2419
			end -- 2419
			shared.error = result.message -- 2422
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2423
			shared.done = true -- 2424
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2425
			persistHistoryState(shared) -- 2429
			return ____awaiter_resolve(nil, "done") -- 2429
		end -- 2429
		if result.directSummary and result.directSummary ~= "" then -- 2429
			shared.response = result.directSummary -- 2433
			shared.done = true -- 2434
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2435
			persistHistoryState(shared) -- 2440
			return ____awaiter_resolve(nil, "done") -- 2440
		end -- 2440
		if result.tool == "finish" then -- 2440
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2444
			shared.response = finalMessage -- 2445
			shared.done = true -- 2446
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2447
			persistHistoryState(shared) -- 2452
			return ____awaiter_resolve(nil, "done") -- 2452
		end -- 2452
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2455
		shared.step = shared.step + 1 -- 2456
		local step = shared.step -- 2457
		emitAgentEvent(shared, { -- 2458
			type = "decision_made", -- 2459
			sessionId = shared.sessionId, -- 2460
			taskId = shared.taskId, -- 2461
			step = step, -- 2462
			tool = result.tool, -- 2463
			reason = result.reason, -- 2464
			reasoningContent = result.reasoningContent, -- 2465
			params = result.params -- 2466
		}) -- 2466
		local ____shared_history_45 = shared.history -- 2466
		____shared_history_45[#____shared_history_45 + 1] = { -- 2468
			step = step, -- 2469
			toolCallId = toolCallId, -- 2470
			tool = result.tool, -- 2471
			reason = result.reason or "", -- 2472
			reasoningContent = result.reasoningContent, -- 2473
			params = result.params, -- 2474
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2475
		} -- 2475
		appendConversationMessage( -- 2477
			shared, -- 2477
			{ -- 2477
				role = "assistant", -- 2478
				content = result.reason or "", -- 2479
				reasoning_content = result.reasoningContent, -- 2480
				tool_calls = {{ -- 2481
					id = toolCallId, -- 2482
					type = "function", -- 2483
					["function"] = { -- 2484
						name = result.tool, -- 2485
						arguments = toJson(result.params) -- 2486
					} -- 2486
				}} -- 2486
			} -- 2486
		) -- 2486
		persistHistoryState(shared) -- 2490
		return ____awaiter_resolve(nil, result.tool) -- 2490
	end) -- 2490
end -- 2414
local ReadFileAction = __TS__Class() -- 2495
ReadFileAction.name = "ReadFileAction" -- 2495
__TS__ClassExtends(ReadFileAction, Node) -- 2495
function ReadFileAction.prototype.prep(self, shared) -- 2496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2496
		local last = shared.history[#shared.history] -- 2497
		if not last then -- 2497
			error( -- 2498
				__TS__New(Error, "no history"), -- 2498
				0 -- 2498
			) -- 2498
		end -- 2498
		emitAgentStartEvent(shared, last) -- 2499
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2500
		if __TS__StringTrim(path) == "" then -- 2500
			error( -- 2503
				__TS__New(Error, "missing path"), -- 2503
				0 -- 2503
			) -- 2503
		end -- 2503
		local ____path_48 = path -- 2505
		local ____shared_workingDir_49 = shared.workingDir -- 2507
		local ____temp_50 = shared.useChineseResponse and "zh" or "en" -- 2508
		local ____last_params_startLine_46 = last.params.startLine -- 2509
		if ____last_params_startLine_46 == nil then -- 2509
			____last_params_startLine_46 = 1 -- 2509
		end -- 2509
		local ____TS__Number_result_51 = __TS__Number(____last_params_startLine_46) -- 2509
		local ____last_params_endLine_47 = last.params.endLine -- 2510
		if ____last_params_endLine_47 == nil then -- 2510
			____last_params_endLine_47 = READ_FILE_DEFAULT_LIMIT -- 2510
		end -- 2510
		return ____awaiter_resolve( -- 2510
			nil, -- 2510
			{ -- 2504
				path = ____path_48, -- 2505
				tool = "read_file", -- 2506
				workDir = ____shared_workingDir_49, -- 2507
				docLanguage = ____temp_50, -- 2508
				startLine = ____TS__Number_result_51, -- 2509
				endLine = __TS__Number(____last_params_endLine_47) -- 2510
			} -- 2510
		) -- 2510
	end) -- 2510
end -- 2496
function ReadFileAction.prototype.exec(self, input) -- 2514
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2514
		return ____awaiter_resolve( -- 2514
			nil, -- 2514
			Tools.readFile( -- 2515
				input.workDir, -- 2516
				input.path, -- 2517
				__TS__Number(input.startLine or 1), -- 2518
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2519
				input.docLanguage -- 2520
			) -- 2520
		) -- 2520
	end) -- 2520
end -- 2514
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2524
		local result = execRes -- 2525
		local last = shared.history[#shared.history] -- 2526
		if last ~= nil then -- 2526
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2528
			appendToolResultMessage(shared, last) -- 2529
			emitAgentFinishEvent(shared, last) -- 2530
		end -- 2530
		persistHistoryState(shared) -- 2532
		__TS__Await(maybeCompressHistory(shared)) -- 2533
		persistHistoryState(shared) -- 2534
		return ____awaiter_resolve(nil, "main") -- 2534
	end) -- 2534
end -- 2524
local SearchFilesAction = __TS__Class() -- 2539
SearchFilesAction.name = "SearchFilesAction" -- 2539
__TS__ClassExtends(SearchFilesAction, Node) -- 2539
function SearchFilesAction.prototype.prep(self, shared) -- 2540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2540
		local last = shared.history[#shared.history] -- 2541
		if not last then -- 2541
			error( -- 2542
				__TS__New(Error, "no history"), -- 2542
				0 -- 2542
			) -- 2542
		end -- 2542
		emitAgentStartEvent(shared, last) -- 2543
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2543
	end) -- 2543
end -- 2540
function SearchFilesAction.prototype.exec(self, input) -- 2547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2547
		local params = input.params -- 2548
		local ____Tools_searchFiles_65 = Tools.searchFiles -- 2549
		local ____input_workDir_58 = input.workDir -- 2550
		local ____temp_59 = params.path or "" -- 2551
		local ____temp_60 = params.pattern or "" -- 2552
		local ____params_globs_61 = params.globs -- 2553
		local ____params_useRegex_62 = params.useRegex -- 2554
		local ____params_caseSensitive_63 = params.caseSensitive -- 2555
		local ____math_max_54 = math.max -- 2558
		local ____math_floor_53 = math.floor -- 2558
		local ____params_limit_52 = params.limit -- 2558
		if ____params_limit_52 == nil then -- 2558
			____params_limit_52 = SEARCH_FILES_LIMIT_DEFAULT -- 2558
		end -- 2558
		local ____math_max_54_result_64 = ____math_max_54( -- 2558
			1, -- 2558
			____math_floor_53(__TS__Number(____params_limit_52)) -- 2558
		) -- 2558
		local ____math_max_57 = math.max -- 2559
		local ____math_floor_56 = math.floor -- 2559
		local ____params_offset_55 = params.offset -- 2559
		if ____params_offset_55 == nil then -- 2559
			____params_offset_55 = 0 -- 2559
		end -- 2559
		local result = __TS__Await(____Tools_searchFiles_65({ -- 2549
			workDir = ____input_workDir_58, -- 2550
			path = ____temp_59, -- 2551
			pattern = ____temp_60, -- 2552
			globs = ____params_globs_61, -- 2553
			useRegex = ____params_useRegex_62, -- 2554
			caseSensitive = ____params_caseSensitive_63, -- 2555
			includeContent = true, -- 2556
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2557
			limit = ____math_max_54_result_64, -- 2558
			offset = ____math_max_57( -- 2559
				0, -- 2559
				____math_floor_56(__TS__Number(____params_offset_55)) -- 2559
			), -- 2559
			groupByFile = params.groupByFile == true -- 2560
		})) -- 2560
		return ____awaiter_resolve(nil, result) -- 2560
	end) -- 2560
end -- 2547
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2565
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2565
		local last = shared.history[#shared.history] -- 2566
		if last ~= nil then -- 2566
			local result = execRes -- 2568
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2569
			appendToolResultMessage(shared, last) -- 2570
			emitAgentFinishEvent(shared, last) -- 2571
		end -- 2571
		persistHistoryState(shared) -- 2573
		__TS__Await(maybeCompressHistory(shared)) -- 2574
		persistHistoryState(shared) -- 2575
		return ____awaiter_resolve(nil, "main") -- 2575
	end) -- 2575
end -- 2565
local SearchDoraAPIAction = __TS__Class() -- 2580
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2580
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2580
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2581
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2581
		local last = shared.history[#shared.history] -- 2582
		if not last then -- 2582
			error( -- 2583
				__TS__New(Error, "no history"), -- 2583
				0 -- 2583
			) -- 2583
		end -- 2583
		emitAgentStartEvent(shared, last) -- 2584
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2584
	end) -- 2584
end -- 2581
function SearchDoraAPIAction.prototype.exec(self, input) -- 2588
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2588
		local params = input.params -- 2589
		local ____Tools_searchDoraAPI_73 = Tools.searchDoraAPI -- 2590
		local ____temp_69 = params.pattern or "" -- 2591
		local ____temp_70 = params.docSource or "api" -- 2592
		local ____temp_71 = input.useChineseResponse and "zh" or "en" -- 2593
		local ____temp_72 = params.programmingLanguage or "ts" -- 2594
		local ____math_min_68 = math.min -- 2595
		local ____math_max_67 = math.max -- 2595
		local ____params_limit_66 = params.limit -- 2595
		if ____params_limit_66 == nil then -- 2595
			____params_limit_66 = 8 -- 2595
		end -- 2595
		local result = __TS__Await(____Tools_searchDoraAPI_73({ -- 2590
			pattern = ____temp_69, -- 2591
			docSource = ____temp_70, -- 2592
			docLanguage = ____temp_71, -- 2593
			programmingLanguage = ____temp_72, -- 2594
			limit = ____math_min_68( -- 2595
				SEARCH_DORA_API_LIMIT_MAX, -- 2595
				____math_max_67( -- 2595
					1, -- 2595
					__TS__Number(____params_limit_66) -- 2595
				) -- 2595
			), -- 2595
			useRegex = params.useRegex, -- 2596
			caseSensitive = false, -- 2597
			includeContent = true, -- 2598
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2599
		})) -- 2599
		return ____awaiter_resolve(nil, result) -- 2599
	end) -- 2599
end -- 2588
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2604
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2604
		local last = shared.history[#shared.history] -- 2605
		if last ~= nil then -- 2605
			local result = execRes -- 2607
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2608
			appendToolResultMessage(shared, last) -- 2609
			emitAgentFinishEvent(shared, last) -- 2610
		end -- 2610
		persistHistoryState(shared) -- 2612
		__TS__Await(maybeCompressHistory(shared)) -- 2613
		persistHistoryState(shared) -- 2614
		return ____awaiter_resolve(nil, "main") -- 2614
	end) -- 2614
end -- 2604
local ListFilesAction = __TS__Class() -- 2619
ListFilesAction.name = "ListFilesAction" -- 2619
__TS__ClassExtends(ListFilesAction, Node) -- 2619
function ListFilesAction.prototype.prep(self, shared) -- 2620
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2620
		local last = shared.history[#shared.history] -- 2621
		if not last then -- 2621
			error( -- 2622
				__TS__New(Error, "no history"), -- 2622
				0 -- 2622
			) -- 2622
		end -- 2622
		emitAgentStartEvent(shared, last) -- 2623
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2623
	end) -- 2623
end -- 2620
function ListFilesAction.prototype.exec(self, input) -- 2627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2627
		local params = input.params -- 2628
		local ____Tools_listFiles_80 = Tools.listFiles -- 2629
		local ____input_workDir_77 = input.workDir -- 2630
		local ____temp_78 = params.path or "" -- 2631
		local ____params_globs_79 = params.globs -- 2632
		local ____math_max_76 = math.max -- 2633
		local ____math_floor_75 = math.floor -- 2633
		local ____params_maxEntries_74 = params.maxEntries -- 2633
		if ____params_maxEntries_74 == nil then -- 2633
			____params_maxEntries_74 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2633
		end -- 2633
		local result = ____Tools_listFiles_80({ -- 2629
			workDir = ____input_workDir_77, -- 2630
			path = ____temp_78, -- 2631
			globs = ____params_globs_79, -- 2632
			maxEntries = ____math_max_76( -- 2633
				1, -- 2633
				____math_floor_75(__TS__Number(____params_maxEntries_74)) -- 2633
			) -- 2633
		}) -- 2633
		return ____awaiter_resolve(nil, result) -- 2633
	end) -- 2633
end -- 2627
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2638
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2638
		local last = shared.history[#shared.history] -- 2639
		if last ~= nil then -- 2639
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2641
			appendToolResultMessage(shared, last) -- 2642
			emitAgentFinishEvent(shared, last) -- 2643
		end -- 2643
		persistHistoryState(shared) -- 2645
		__TS__Await(maybeCompressHistory(shared)) -- 2646
		persistHistoryState(shared) -- 2647
		return ____awaiter_resolve(nil, "main") -- 2647
	end) -- 2647
end -- 2638
local DeleteFileAction = __TS__Class() -- 2652
DeleteFileAction.name = "DeleteFileAction" -- 2652
__TS__ClassExtends(DeleteFileAction, Node) -- 2652
function DeleteFileAction.prototype.prep(self, shared) -- 2653
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2653
		local last = shared.history[#shared.history] -- 2654
		if not last then -- 2654
			error( -- 2655
				__TS__New(Error, "no history"), -- 2655
				0 -- 2655
			) -- 2655
		end -- 2655
		emitAgentStartEvent(shared, last) -- 2656
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2657
		if __TS__StringTrim(targetFile) == "" then -- 2657
			error( -- 2660
				__TS__New(Error, "missing target_file"), -- 2660
				0 -- 2660
			) -- 2660
		end -- 2660
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2660
	end) -- 2660
end -- 2653
function DeleteFileAction.prototype.exec(self, input) -- 2664
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2664
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2665
		if not result.success then -- 2665
			return ____awaiter_resolve(nil, result) -- 2665
		end -- 2665
		return ____awaiter_resolve(nil, { -- 2665
			success = true, -- 2673
			changed = true, -- 2674
			mode = "delete", -- 2675
			checkpointId = result.checkpointId, -- 2676
			checkpointSeq = result.checkpointSeq, -- 2677
			files = {{path = input.targetFile, op = "delete"}} -- 2678
		}) -- 2678
	end) -- 2678
end -- 2664
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2682
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2682
		local last = shared.history[#shared.history] -- 2683
		if last ~= nil then -- 2683
			last.result = execRes -- 2685
			appendToolResultMessage(shared, last) -- 2686
			emitAgentFinishEvent(shared, last) -- 2687
			local result = last.result -- 2688
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2688
				emitAgentEvent(shared, { -- 2693
					type = "checkpoint_created", -- 2694
					sessionId = shared.sessionId, -- 2695
					taskId = shared.taskId, -- 2696
					step = last.step, -- 2697
					tool = "delete_file", -- 2698
					checkpointId = result.checkpointId, -- 2699
					checkpointSeq = result.checkpointSeq, -- 2700
					files = result.files -- 2701
				}) -- 2701
			end -- 2701
		end -- 2701
		persistHistoryState(shared) -- 2705
		__TS__Await(maybeCompressHistory(shared)) -- 2706
		persistHistoryState(shared) -- 2707
		return ____awaiter_resolve(nil, "main") -- 2707
	end) -- 2707
end -- 2682
local BuildAction = __TS__Class() -- 2712
BuildAction.name = "BuildAction" -- 2712
__TS__ClassExtends(BuildAction, Node) -- 2712
function BuildAction.prototype.prep(self, shared) -- 2713
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2713
		local last = shared.history[#shared.history] -- 2714
		if not last then -- 2714
			error( -- 2715
				__TS__New(Error, "no history"), -- 2715
				0 -- 2715
			) -- 2715
		end -- 2715
		emitAgentStartEvent(shared, last) -- 2716
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2716
	end) -- 2716
end -- 2713
function BuildAction.prototype.exec(self, input) -- 2720
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2720
		local params = input.params -- 2721
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2722
		return ____awaiter_resolve(nil, result) -- 2722
	end) -- 2722
end -- 2720
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2729
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2729
		local last = shared.history[#shared.history] -- 2730
		if last ~= nil then -- 2730
			last.result = execRes -- 2732
			appendToolResultMessage(shared, last) -- 2733
			emitAgentFinishEvent(shared, last) -- 2734
		end -- 2734
		persistHistoryState(shared) -- 2736
		__TS__Await(maybeCompressHistory(shared)) -- 2737
		persistHistoryState(shared) -- 2738
		return ____awaiter_resolve(nil, "main") -- 2738
	end) -- 2738
end -- 2729
local SpawnSubAgentAction = __TS__Class() -- 2743
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2743
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2743
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2744
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2744
		local last = shared.history[#shared.history] -- 2753
		if not last then -- 2753
			error( -- 2754
				__TS__New(Error, "no history"), -- 2754
				0 -- 2754
			) -- 2754
		end -- 2754
		emitAgentStartEvent(shared, last) -- 2755
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2756
			last.params.filesHint, -- 2757
			function(____, item) return type(item) == "string" end -- 2757
		) or nil -- 2757
		return ____awaiter_resolve( -- 2757
			nil, -- 2757
			{ -- 2759
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2760
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2761
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2762
				filesHint = filesHint, -- 2763
				sessionId = shared.sessionId, -- 2764
				projectRoot = shared.workingDir, -- 2765
				spawnSubAgent = shared.spawnSubAgent -- 2766
			} -- 2766
		) -- 2766
	end) -- 2766
end -- 2744
function SpawnSubAgentAction.prototype.exec(self, input) -- 2770
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2770
		if not input.spawnSubAgent then -- 2770
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2770
		end -- 2770
		if input.sessionId == nil or input.sessionId <= 0 then -- 2770
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2770
		end -- 2770
		local ____Log_86 = Log -- 2785
		local ____temp_83 = #input.title -- 2785
		local ____temp_84 = #input.prompt -- 2785
		local ____temp_85 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2785
		local ____opt_81 = input.filesHint -- 2785
		____Log_86( -- 2785
			"Info", -- 2785
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_83)) .. " prompt_len=") .. tostring(____temp_84)) .. " expected_len=") .. tostring(____temp_85)) .. " files_hint_count=") .. tostring(____opt_81 and #____opt_81 or 0) -- 2785
		) -- 2785
		local result = __TS__Await(input:spawnSubAgent({ -- 2786
			parentSessionId = input.sessionId, -- 2787
			projectRoot = input.projectRoot, -- 2788
			title = input.title, -- 2789
			prompt = input.prompt, -- 2790
			expectedOutput = input.expectedOutput, -- 2791
			filesHint = input.filesHint -- 2792
		})) -- 2792
		if not result.success then -- 2792
			return ____awaiter_resolve(nil, result) -- 2792
		end -- 2792
		return ____awaiter_resolve(nil, {success = true, sessionId = result.sessionId, taskId = result.taskId, title = result.title}) -- 2792
	end) -- 2792
end -- 2770
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 2805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2805
		local last = shared.history[#shared.history] -- 2806
		if last ~= nil then -- 2806
			last.result = execRes -- 2808
			appendToolResultMessage(shared, last) -- 2809
			emitAgentFinishEvent(shared, last) -- 2810
		end -- 2810
		persistHistoryState(shared) -- 2812
		__TS__Await(maybeCompressHistory(shared)) -- 2813
		persistHistoryState(shared) -- 2814
		return ____awaiter_resolve(nil, "main") -- 2814
	end) -- 2814
end -- 2805
local EditFileAction = __TS__Class() -- 2819
EditFileAction.name = "EditFileAction" -- 2819
__TS__ClassExtends(EditFileAction, Node) -- 2819
function EditFileAction.prototype.prep(self, shared) -- 2820
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2820
		local last = shared.history[#shared.history] -- 2821
		if not last then -- 2821
			error( -- 2822
				__TS__New(Error, "no history"), -- 2822
				0 -- 2822
			) -- 2822
		end -- 2822
		emitAgentStartEvent(shared, last) -- 2823
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2824
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2827
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2828
		if __TS__StringTrim(path) == "" then -- 2828
			error( -- 2829
				__TS__New(Error, "missing path"), -- 2829
				0 -- 2829
			) -- 2829
		end -- 2829
		return ____awaiter_resolve(nil, { -- 2829
			path = path, -- 2830
			oldStr = oldStr, -- 2830
			newStr = newStr, -- 2830
			taskId = shared.taskId, -- 2830
			workDir = shared.workingDir -- 2830
		}) -- 2830
	end) -- 2830
end -- 2820
function EditFileAction.prototype.exec(self, input) -- 2833
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2833
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2834
		if not readRes.success then -- 2834
			if input.oldStr ~= "" then -- 2834
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2834
			end -- 2834
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2839
			if not createRes.success then -- 2839
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2839
			end -- 2839
			return ____awaiter_resolve(nil, { -- 2839
				success = true, -- 2847
				changed = true, -- 2848
				mode = "create", -- 2849
				checkpointId = createRes.checkpointId, -- 2850
				checkpointSeq = createRes.checkpointSeq, -- 2851
				files = {{path = input.path, op = "create"}} -- 2852
			}) -- 2852
		end -- 2852
		if input.oldStr == "" then -- 2852
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2856
			if not overwriteRes.success then -- 2856
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2856
			end -- 2856
			return ____awaiter_resolve(nil, { -- 2856
				success = true, -- 2864
				changed = true, -- 2865
				mode = "overwrite", -- 2866
				checkpointId = overwriteRes.checkpointId, -- 2867
				checkpointSeq = overwriteRes.checkpointSeq, -- 2868
				files = {{path = input.path, op = "write"}} -- 2869
			}) -- 2869
		end -- 2869
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2874
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2875
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2876
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2879
		if occurrences == 0 then -- 2879
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2881
			if not indentTolerant.success then -- 2881
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2881
			end -- 2881
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2885
			if not applyRes.success then -- 2885
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2885
			end -- 2885
			return ____awaiter_resolve(nil, { -- 2885
				success = true, -- 2893
				changed = true, -- 2894
				mode = "replace_indent_tolerant", -- 2895
				checkpointId = applyRes.checkpointId, -- 2896
				checkpointSeq = applyRes.checkpointSeq, -- 2897
				files = {{path = input.path, op = "write"}} -- 2898
			}) -- 2898
		end -- 2898
		if occurrences > 1 then -- 2898
			return ____awaiter_resolve( -- 2898
				nil, -- 2898
				{ -- 2902
					success = false, -- 2902
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2902
				} -- 2902
			) -- 2902
		end -- 2902
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2906
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2907
		if not applyRes.success then -- 2907
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2907
		end -- 2907
		return ____awaiter_resolve(nil, { -- 2907
			success = true, -- 2915
			changed = true, -- 2916
			mode = "replace", -- 2917
			checkpointId = applyRes.checkpointId, -- 2918
			checkpointSeq = applyRes.checkpointSeq, -- 2919
			files = {{path = input.path, op = "write"}} -- 2920
		}) -- 2920
	end) -- 2920
end -- 2833
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2924
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2924
		local last = shared.history[#shared.history] -- 2925
		if last ~= nil then -- 2925
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2927
			last.result = execRes -- 2928
			appendToolResultMessage(shared, last) -- 2929
			emitAgentFinishEvent(shared, last) -- 2930
			local result = last.result -- 2931
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2931
				emitAgentEvent(shared, { -- 2936
					type = "checkpoint_created", -- 2937
					sessionId = shared.sessionId, -- 2938
					taskId = shared.taskId, -- 2939
					step = last.step, -- 2940
					tool = last.tool, -- 2941
					checkpointId = result.checkpointId, -- 2942
					checkpointSeq = result.checkpointSeq, -- 2943
					files = result.files -- 2944
				}) -- 2944
			end -- 2944
		end -- 2944
		persistHistoryState(shared) -- 2948
		__TS__Await(maybeCompressHistory(shared)) -- 2949
		persistHistoryState(shared) -- 2950
		return ____awaiter_resolve(nil, "main") -- 2950
	end) -- 2950
end -- 2924
local EndNode = __TS__Class() -- 2955
EndNode.name = "EndNode" -- 2955
__TS__ClassExtends(EndNode, Node) -- 2955
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2956
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2956
		return ____awaiter_resolve(nil, nil) -- 2956
	end) -- 2956
end -- 2956
local CodingAgentFlow = __TS__Class() -- 2961
CodingAgentFlow.name = "CodingAgentFlow" -- 2961
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2961
function CodingAgentFlow.prototype.____constructor(self, role) -- 2962
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2963
	local read = __TS__New(ReadFileAction, 1, 0) -- 2964
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2965
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2966
	local list = __TS__New(ListFilesAction, 1, 0) -- 2967
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2968
	local build = __TS__New(BuildAction, 1, 0) -- 2969
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 2970
	local edit = __TS__New(EditFileAction, 1, 0) -- 2971
	local done = __TS__New(EndNode, 1, 0) -- 2972
	main:on("grep_files", search) -- 2974
	main:on("search_dora_api", searchDora) -- 2975
	main:on("glob_files", list) -- 2976
	if role == "main" then -- 2976
		main:on("read_file", read) -- 2978
		main:on("spawn_sub_agent", spawn) -- 2979
	else -- 2979
		main:on("read_file", read) -- 2981
		main:on("delete_file", del) -- 2982
		main:on("build", build) -- 2983
		main:on("edit_file", edit) -- 2984
	end -- 2984
	main:on("done", done) -- 2986
	search:on("main", main) -- 2988
	searchDora:on("main", main) -- 2989
	list:on("main", main) -- 2990
	spawn:on("main", main) -- 2991
	read:on("main", main) -- 2992
	del:on("main", main) -- 2993
	build:on("main", main) -- 2994
	edit:on("main", main) -- 2995
	Flow.prototype.____constructor(self, main) -- 2997
end -- 2962
local function runCodingAgentAsync(options) -- 3019
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3019
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3019
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3019
		end -- 3019
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3023
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3024
		if not llmConfigRes.success then -- 3024
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3024
		end -- 3024
		local llmConfig = llmConfigRes.config -- 3030
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3031
		if not taskRes.success then -- 3031
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3031
		end -- 3031
		local compressor = __TS__New(MemoryCompressor, { -- 3038
			compressionThreshold = 0.8, -- 3039
			compressionTargetThreshold = 0.5, -- 3040
			maxCompressionRounds = 3, -- 3041
			projectDir = options.workDir, -- 3042
			llmConfig = llmConfig, -- 3043
			promptPack = options.promptPack, -- 3044
			scope = options.memoryScope -- 3045
		}) -- 3045
		local persistedSession = compressor:getStorage():readSessionState() -- 3047
		local promptPack = compressor:getPromptPack() -- 3048
		local shared = { -- 3050
			sessionId = options.sessionId, -- 3051
			taskId = taskRes.taskId, -- 3052
			role = options.role or "main", -- 3053
			maxSteps = math.max( -- 3054
				1, -- 3054
				math.floor(options.maxSteps or 50) -- 3054
			), -- 3054
			llmMaxTry = math.max( -- 3055
				1, -- 3055
				math.floor(options.llmMaxTry or 5) -- 3055
			), -- 3055
			step = 0, -- 3056
			done = false, -- 3057
			stopToken = options.stopToken or ({stopped = false}), -- 3058
			response = "", -- 3059
			userQuery = normalizedPrompt, -- 3060
			workingDir = options.workDir, -- 3061
			useChineseResponse = options.useChineseResponse == true, -- 3062
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3063
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 3066
			llmConfig = llmConfig, -- 3071
			onEvent = options.onEvent, -- 3072
			promptPack = promptPack, -- 3073
			history = {}, -- 3074
			messages = persistedSession.messages, -- 3075
			memory = {compressor = compressor}, -- 3077
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3081
			spawnSubAgent = options.spawnSubAgent -- 3086
		} -- 3086
		local ____try = __TS__AsyncAwaiter(function() -- 3086
			emitAgentEvent(shared, { -- 3090
				type = "task_started", -- 3091
				sessionId = shared.sessionId, -- 3092
				taskId = shared.taskId, -- 3093
				prompt = shared.userQuery, -- 3094
				workDir = shared.workingDir, -- 3095
				maxSteps = shared.maxSteps -- 3096
			}) -- 3096
			if shared.stopToken.stopped then -- 3096
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3099
				return ____awaiter_resolve( -- 3099
					nil, -- 3099
					emitAgentTaskFinishEvent( -- 3100
						shared, -- 3100
						false, -- 3100
						getCancelledReason(shared) -- 3100
					) -- 3100
				) -- 3100
			end -- 3100
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3102
			local promptCommand = getPromptCommand(shared.userQuery) -- 3103
			if promptCommand == "reset" then -- 3103
				return ____awaiter_resolve( -- 3103
					nil, -- 3103
					resetSessionHistory(shared) -- 3105
				) -- 3105
			end -- 3105
			if promptCommand == "compact" then -- 3105
				return ____awaiter_resolve( -- 3105
					nil, -- 3105
					__TS__Await(compactAllHistory(shared)) -- 3108
				) -- 3108
			end -- 3108
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3110
			persistHistoryState(shared) -- 3114
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3115
			__TS__Await(flow:run(shared)) -- 3116
			if shared.stopToken.stopped then -- 3116
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3118
				return ____awaiter_resolve( -- 3118
					nil, -- 3118
					emitAgentTaskFinishEvent( -- 3119
						shared, -- 3119
						false, -- 3119
						getCancelledReason(shared) -- 3119
					) -- 3119
				) -- 3119
			end -- 3119
			if shared.error then -- 3119
				return ____awaiter_resolve( -- 3119
					nil, -- 3119
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3122
				) -- 3122
			end -- 3122
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3125
			return ____awaiter_resolve( -- 3125
				nil, -- 3125
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3126
			) -- 3126
		end) -- 3126
		__TS__Await(____try.catch( -- 3089
			____try, -- 3089
			function(____, e) -- 3089
				return ____awaiter_resolve( -- 3089
					nil, -- 3089
					finalizeAgentFailure( -- 3129
						shared, -- 3129
						tostring(e) -- 3129
					) -- 3129
				) -- 3129
			end -- 3129
		)) -- 3129
	end) -- 3129
end -- 3019
function ____exports.runCodingAgent(options, callback) -- 3133
	local ____self_87 = runCodingAgentAsync(options) -- 3133
	____self_87["then"]( -- 3133
		____self_87, -- 3133
		function(____, result) return callback(result) end -- 3134
	) -- 3134
end -- 3133
return ____exports -- 3133