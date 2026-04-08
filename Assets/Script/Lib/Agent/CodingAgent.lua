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
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
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
local stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, persistHistoryState, applyCompressedSessionState, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, SEARCH_DORA_API_LIMIT_MAX -- 1
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
function emitAgentEvent(shared, event) -- 628
	if shared.onEvent then -- 628
		do -- 628
			local function ____catch(____error) -- 628
				Log( -- 633
					"Error", -- 633
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 633
				) -- 633
			end -- 633
			local ____try, ____hasReturned = pcall(function() -- 633
				shared:onEvent(event) -- 631
			end) -- 631
			if not ____try then -- 631
				____catch(____hasReturned) -- 631
			end -- 631
		end -- 631
	end -- 631
end -- 631
function truncateText(text, maxLen) -- 877
	if #text <= maxLen then -- 877
		return text -- 878
	end -- 878
	local nextPos = utf8.offset(text, maxLen + 1) -- 879
	if nextPos == nil then -- 879
		return text -- 880
	end -- 880
	return string.sub(text, 1, nextPos - 1) .. "..." -- 881
end -- 881
function getReplyLanguageDirective(shared) -- 891
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 892
end -- 892
function replacePromptVars(template, vars) -- 897
	local output = template -- 898
	for key in pairs(vars) do -- 899
		output = table.concat( -- 900
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 900
			vars[key] or "" or "," -- 900
		) -- 900
	end -- 900
	return output -- 902
end -- 902
function getDecisionToolDefinitions(shared) -- 1026
	local base = replacePromptVars( -- 1027
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1028
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1029
	) -- 1029
	if (shared and shared.decisionMode) ~= "xml" then -- 1029
		return base -- 1032
	end -- 1032
	return base .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1034
end -- 1034
function persistHistoryState(shared) -- 1283
	shared.memory.compressor:getStorage():writeSessionState(shared.messages) -- 1284
end -- 1284
function applyCompressedSessionState(shared, compressedCount, carryMessage) -- 1287
	local remainingMessages = __TS__ArraySlice(shared.messages, compressedCount) -- 1292
	if carryMessage then -- 1292
		__TS__ArrayUnshift( -- 1294
			remainingMessages, -- 1294
			__TS__ObjectAssign( -- 1294
				{}, -- 1294
				carryMessage, -- 1295
				{timestamp = carryMessage.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")} -- 1294
			) -- 1294
		) -- 1294
	end -- 1294
	shared.messages = remainingMessages -- 1299
end -- 1299
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1638
	if includeToolDefinitions == nil then -- 1638
		includeToolDefinitions = false -- 1638
	end -- 1638
	local sections = { -- 1639
		shared.promptPack.agentIdentityPrompt, -- 1640
		getReplyLanguageDirective(shared) -- 1641
	} -- 1641
	local memoryContext = shared.memory.compressor:getStorage():getMemoryContext() -- 1643
	if memoryContext ~= "" then -- 1643
		sections[#sections + 1] = memoryContext -- 1645
	end -- 1645
	if includeToolDefinitions then -- 1645
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1648
		if shared.decisionMode == "xml" then -- 1648
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1650
		end -- 1650
	end -- 1650
	local skillsSection = buildSkillsSection(shared) -- 1654
	if skillsSection ~= "" then -- 1654
		sections[#sections + 1] = skillsSection -- 1656
	end -- 1656
	return table.concat(sections, "\n\n") -- 1658
end -- 1658
function buildSkillsSection(shared) -- 1661
	local ____opt_30 = shared.skills -- 1661
	if not (____opt_30 and ____opt_30.loader) then -- 1661
		return "" -- 1663
	end -- 1663
	return shared.skills.loader:buildSkillsPromptSection() -- 1665
end -- 1665
function buildXmlDecisionInstruction(shared, feedback) -- 1752
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1753
end -- 1753
function emitAgentTaskFinishEvent(shared, success, message) -- 2693
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 2694
	emitAgentEvent(shared, { -- 2700
		type = "task_finished", -- 2701
		sessionId = shared.sessionId, -- 2702
		taskId = shared.taskId, -- 2703
		success = result.success, -- 2704
		message = result.message, -- 2705
		steps = result.steps -- 2706
	}) -- 2706
	return result -- 2708
end -- 2708
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
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 474
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 574
local HISTORY_READ_FILE_MAX_LINES = 300 -- 575
local READ_FILE_DEFAULT_LIMIT = 300 -- 576
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 577
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 578
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 579
SEARCH_DORA_API_LIMIT_MAX = 20 -- 580
local SEARCH_FILES_LIMIT_DEFAULT = 20 -- 581
local LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 582
local SEARCH_PREVIEW_CONTEXT = 80 -- 583
local function emitAgentStartEvent(shared, action) -- 638
	emitAgentEvent(shared, { -- 639
		type = "tool_started", -- 640
		sessionId = shared.sessionId, -- 641
		taskId = shared.taskId, -- 642
		step = action.step, -- 643
		tool = action.tool -- 644
	}) -- 644
end -- 638
local function emitAgentFinishEvent(shared, action) -- 648
	emitAgentEvent(shared, { -- 649
		type = "tool_finished", -- 650
		sessionId = shared.sessionId, -- 651
		taskId = shared.taskId, -- 652
		step = action.step, -- 653
		tool = action.tool, -- 654
		result = action.result or ({}) -- 655
	}) -- 655
end -- 648
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 659
	emitAgentEvent(shared, { -- 660
		type = "assistant_message_updated", -- 661
		sessionId = shared.sessionId, -- 662
		taskId = shared.taskId, -- 663
		step = shared.step + 1, -- 664
		content = content, -- 665
		reasoningContent = reasoningContent -- 666
	}) -- 666
end -- 659
local function getMemoryCompressionStartReason(shared) -- 670
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 671
end -- 670
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 676
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 677
end -- 676
local function getMemoryCompressionFailureReason(shared, ____error) -- 682
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 683
end -- 682
local function summarizeHistoryEntryPreview(text, maxChars) -- 688
	if maxChars == nil then -- 688
		maxChars = 180 -- 688
	end -- 688
	local trimmed = __TS__StringTrim(text) -- 689
	if trimmed == "" then -- 689
		return "" -- 690
	end -- 690
	return truncateText(trimmed, maxChars) -- 691
end -- 688
local function getCancelledReason(shared) -- 694
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 694
		return shared.stopToken.reason -- 695
	end -- 695
	return shared.useChineseResponse and "已取消" or "cancelled" -- 696
end -- 694
local function getMaxStepsReachedReason(shared) -- 699
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps)." -- 700
end -- 699
local function getFailureSummaryFallback(shared, ____error) -- 705
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 706
end -- 705
local function finalizeAgentFailure(shared, ____error) -- 711
	if shared.stopToken.stopped then -- 711
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 713
		return emitAgentTaskFinishEvent( -- 714
			shared, -- 714
			false, -- 714
			getCancelledReason(shared) -- 714
		) -- 714
	end -- 714
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 716
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 717
end -- 711
local function getPromptCommand(prompt) -- 720
	local trimmed = __TS__StringTrim(prompt) -- 721
	if trimmed == "/compact" then -- 721
		return "compact" -- 722
	end -- 722
	if trimmed == "/reset" then -- 722
		return "reset" -- 723
	end -- 723
	return nil -- 724
end -- 720
function ____exports.truncateAgentUserPrompt(prompt) -- 727
	if not prompt then -- 727
		return "" -- 728
	end -- 728
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 728
		return prompt -- 729
	end -- 729
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 730
	if offset == nil then -- 730
		return prompt -- 731
	end -- 731
	return string.sub(prompt, 1, offset - 1) -- 732
end -- 727
local function canWriteStepLLMDebug(shared, stepId) -- 735
	if stepId == nil then -- 735
		stepId = shared.step + 1 -- 735
	end -- 735
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 736
end -- 735
local function ensureDirRecursive(dir) -- 743
	if not dir then -- 743
		return false -- 744
	end -- 744
	if Content:exist(dir) then -- 744
		return Content:isdir(dir) -- 745
	end -- 745
	local parent = Path:getPath(dir) -- 746
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 746
		return false -- 748
	end -- 748
	return Content:mkdir(dir) -- 750
end -- 743
local function encodeDebugJSON(value) -- 753
	local text, err = safeJsonEncode(value) -- 754
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 755
end -- 753
local function getStepLLMDebugDir(shared) -- 758
	return Path( -- 759
		shared.workingDir, -- 760
		".agent", -- 761
		tostring(shared.sessionId), -- 762
		tostring(shared.taskId) -- 763
	) -- 763
end -- 758
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 767
	return Path( -- 768
		getStepLLMDebugDir(shared), -- 768
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 768
	) -- 768
end -- 767
local function getLatestStepLLMDebugSeq(shared, stepId) -- 771
	if not canWriteStepLLMDebug(shared, stepId) then -- 771
		return 0 -- 772
	end -- 772
	local dir = getStepLLMDebugDir(shared) -- 773
	if not Content:exist(dir) or not Content:isdir(dir) then -- 773
		return 0 -- 774
	end -- 774
	local latest = 0 -- 775
	for ____, file in ipairs(Content:getFiles(dir)) do -- 776
		do -- 776
			local name = Path:getFilename(file) -- 777
			local seqText = string.match( -- 778
				name, -- 778
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 778
			) -- 778
			if seqText ~= nil then -- 778
				latest = math.max( -- 780
					latest, -- 780
					tonumber(seqText) -- 780
				) -- 780
				goto __continue115 -- 781
			end -- 781
			local legacyMatch = string.match( -- 783
				name, -- 783
				("^" .. tostring(stepId)) .. "_in%.md$" -- 783
			) -- 783
			if legacyMatch ~= nil then -- 783
				latest = math.max(latest, 1) -- 785
			end -- 785
		end -- 785
		::__continue115:: -- 785
	end -- 785
	return latest -- 788
end -- 771
local function writeStepLLMDebugFile(path, content) -- 791
	if not Content:save(path, content) then -- 791
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 793
		return false -- 794
	end -- 794
	return true -- 796
end -- 791
local function createStepLLMDebugPair(shared, stepId, inContent) -- 799
	if not canWriteStepLLMDebug(shared, stepId) then -- 799
		return 0 -- 800
	end -- 800
	local dir = getStepLLMDebugDir(shared) -- 801
	if not ensureDirRecursive(dir) then -- 801
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 803
		return 0 -- 804
	end -- 804
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 806
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 807
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 808
	if not writeStepLLMDebugFile(inPath, inContent) then -- 808
		return 0 -- 810
	end -- 810
	writeStepLLMDebugFile(outPath, "") -- 812
	return seq -- 813
end -- 799
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 816
	if not canWriteStepLLMDebug(shared, stepId) then -- 816
		return -- 817
	end -- 817
	local dir = getStepLLMDebugDir(shared) -- 818
	if not ensureDirRecursive(dir) then -- 818
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 820
		return -- 821
	end -- 821
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 823
	if latestSeq <= 0 then -- 823
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 825
		writeStepLLMDebugFile(outPath, content) -- 826
		return -- 827
	end -- 827
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 829
	writeStepLLMDebugFile(outPath, content) -- 830
end -- 816
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 833
	if not canWriteStepLLMDebug(shared, stepId) then -- 833
		return -- 834
	end -- 834
	local sections = { -- 835
		"# LLM Input", -- 836
		"session_id: " .. tostring(shared.sessionId), -- 837
		"task_id: " .. tostring(shared.taskId), -- 838
		"step_id: " .. tostring(stepId), -- 839
		"phase: " .. phase, -- 840
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 841
		"## Options", -- 842
		"```json", -- 843
		encodeDebugJSON(options), -- 844
		"```" -- 845
	} -- 845
	do -- 845
		local i = 0 -- 847
		while i < #messages do -- 847
			local message = messages[i + 1] -- 848
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 849
			sections[#sections + 1] = encodeDebugJSON(message) -- 850
			i = i + 1 -- 847
		end -- 847
	end -- 847
	createStepLLMDebugPair( -- 852
		shared, -- 852
		stepId, -- 852
		table.concat(sections, "\n") -- 852
	) -- 852
end -- 833
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 855
	if not canWriteStepLLMDebug(shared, stepId) then -- 855
		return -- 856
	end -- 856
	local ____array_2 = __TS__SparseArrayNew( -- 856
		"# LLM Output", -- 858
		"session_id: " .. tostring(shared.sessionId), -- 859
		"task_id: " .. tostring(shared.taskId), -- 860
		"step_id: " .. tostring(stepId), -- 861
		"phase: " .. phase, -- 862
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 863
		table.unpack(meta and ({ -- 864
			"## Meta", -- 864
			"```json", -- 864
			encodeDebugJSON(meta), -- 864
			"```" -- 864
		}) or ({})) -- 864
	) -- 864
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 864
	local sections = {__TS__SparseArraySpread(____array_2)} -- 857
	updateLatestStepLLMDebugOutput( -- 868
		shared, -- 868
		stepId, -- 868
		table.concat(sections, "\n") -- 868
	) -- 868
end -- 855
local function toJson(value) -- 871
	local text, err = safeJsonEncode(value) -- 872
	if text ~= nil then -- 872
		return text -- 873
	end -- 873
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 874
end -- 871
local function utf8TakeHead(text, maxChars) -- 884
	if maxChars <= 0 or text == "" then -- 884
		return "" -- 885
	end -- 885
	local nextPos = utf8.offset(text, maxChars + 1) -- 886
	if nextPos == nil then -- 886
		return text -- 887
	end -- 887
	return string.sub(text, 1, nextPos - 1) -- 888
end -- 884
local function limitReadContentForHistory(content, tool) -- 905
	local lines = __TS__StringSplit(content, "\n") -- 906
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 907
	local limitedByLines = overLineLimit and table.concat( -- 908
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 909
		"\n" -- 909
	) or content -- 909
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 909
		return content -- 912
	end -- 912
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 914
	local reasons = {} -- 917
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 917
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 918
	end -- 918
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 918
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 919
	end -- 919
	local hint = "Narrow the requested line range." -- 920
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 921
end -- 905
local function summarizeEditTextParamForHistory(value, key) -- 924
	if type(value) ~= "string" then -- 924
		return nil -- 925
	end -- 925
	local text = value -- 926
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 927
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 928
end -- 924
local function sanitizeReadResultForHistory(tool, result) -- 936
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 936
		return result -- 938
	end -- 938
	local clone = {} -- 940
	for key in pairs(result) do -- 941
		clone[key] = result[key] -- 942
	end -- 942
	clone.content = limitReadContentForHistory(result.content, tool) -- 944
	return clone -- 945
end -- 936
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 948
	local shown = math.min(#items, maxItems) -- 952
	local out = {} -- 953
	do -- 953
		local i = 0 -- 954
		while i < shown do -- 954
			local row = items[i + 1] -- 955
			out[#out + 1] = { -- 956
				file = row.file, -- 957
				line = row.line, -- 958
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 959
			} -- 959
			i = i + 1 -- 954
		end -- 954
	end -- 954
	return out -- 964
end -- 948
local function sanitizeSearchResultForHistory(tool, result) -- 967
	if result.success ~= true or not isArray(result.results) then -- 967
		return result -- 971
	end -- 971
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 971
		return result -- 972
	end -- 972
	local clone = {} -- 973
	for key in pairs(result) do -- 974
		clone[key] = result[key] -- 975
	end -- 975
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 977
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 978
	if tool == "grep_files" and isArray(result.groupedResults) then -- 978
		local grouped = result.groupedResults -- 983
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 984
		local sanitizedGroups = {} -- 985
		do -- 985
			local i = 0 -- 986
			while i < shown do -- 986
				local row = grouped[i + 1] -- 987
				sanitizedGroups[#sanitizedGroups + 1] = { -- 988
					file = row.file, -- 989
					totalMatches = row.totalMatches, -- 990
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 991
				} -- 991
				i = i + 1 -- 986
			end -- 986
		end -- 986
		clone.groupedResults = sanitizedGroups -- 996
	end -- 996
	return clone -- 998
end -- 967
local function sanitizeListFilesResultForHistory(result) -- 1001
	if result.success ~= true or not isArray(result.files) then -- 1001
		return result -- 1002
	end -- 1002
	local clone = {} -- 1003
	for key in pairs(result) do -- 1004
		clone[key] = result[key] -- 1005
	end -- 1005
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1007
	return clone -- 1008
end -- 1001
local function sanitizeActionParamsForHistory(tool, params) -- 1011
	if tool ~= "edit_file" then -- 1011
		return params -- 1012
	end -- 1012
	local clone = {} -- 1013
	for key in pairs(params) do -- 1014
		if key == "old_str" then -- 1014
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1016
		elseif key == "new_str" then -- 1016
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1018
		else -- 1018
			clone[key] = params[key] -- 1020
		end -- 1020
	end -- 1020
	return clone -- 1023
end -- 1011
local function maybeCompressHistory(shared) -- 1043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1043
		local ____shared_7 = shared -- 1044
		local memory = ____shared_7.memory -- 1044
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1045
		local changed = false -- 1046
		do -- 1046
			local round = 0 -- 1047
			while round < maxRounds do -- 1047
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1048
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1052
				if not memory.compressor:shouldCompress(shared.messages, systemPrompt, toolDefinitions) then -- 1052
					if changed then -- 1052
						persistHistoryState(shared) -- 1061
					end -- 1061
					return ____awaiter_resolve(nil) -- 1061
				end -- 1061
				local compressionRound = round + 1 -- 1065
				shared.step = shared.step + 1 -- 1066
				local stepId = shared.step -- 1067
				local pendingMessages = #shared.messages -- 1068
				emitAgentEvent( -- 1069
					shared, -- 1069
					{ -- 1069
						type = "memory_compression_started", -- 1070
						sessionId = shared.sessionId, -- 1071
						taskId = shared.taskId, -- 1072
						step = stepId, -- 1073
						tool = "compress_memory", -- 1074
						reason = getMemoryCompressionStartReason(shared), -- 1075
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1076
					} -- 1076
				) -- 1076
				local result = __TS__Await(memory.compressor:compress( -- 1082
					shared.messages, -- 1083
					systemPrompt, -- 1084
					toolDefinitions, -- 1085
					shared.llmOptions, -- 1086
					shared.llmMaxTry, -- 1087
					shared.decisionMode, -- 1088
					{ -- 1089
						onInput = function(____, phase, messages, options) -- 1090
							saveStepLLMDebugInput( -- 1091
								shared, -- 1091
								stepId, -- 1091
								phase, -- 1091
								messages, -- 1091
								options -- 1091
							) -- 1091
						end, -- 1090
						onOutput = function(____, phase, text, meta) -- 1093
							saveStepLLMDebugOutput( -- 1094
								shared, -- 1094
								stepId, -- 1094
								phase, -- 1094
								text, -- 1094
								meta -- 1094
							) -- 1094
						end -- 1093
					} -- 1093
				)) -- 1093
				if not (result and result.success and result.compressedCount > 0) then -- 1093
					emitAgentEvent( -- 1099
						shared, -- 1099
						{ -- 1099
							type = "memory_compression_finished", -- 1100
							sessionId = shared.sessionId, -- 1101
							taskId = shared.taskId, -- 1102
							step = stepId, -- 1103
							tool = "compress_memory", -- 1104
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1105
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1109
						} -- 1109
					) -- 1109
					if changed then -- 1109
						persistHistoryState(shared) -- 1117
					end -- 1117
					return ____awaiter_resolve(nil) -- 1117
				end -- 1117
				emitAgentEvent( -- 1121
					shared, -- 1121
					{ -- 1121
						type = "memory_compression_finished", -- 1122
						sessionId = shared.sessionId, -- 1123
						taskId = shared.taskId, -- 1124
						step = stepId, -- 1125
						tool = "compress_memory", -- 1126
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1127
						result = { -- 1128
							success = true, -- 1129
							round = compressionRound, -- 1130
							compressedCount = result.compressedCount, -- 1131
							historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry) -- 1132
						} -- 1132
					} -- 1132
				) -- 1132
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1135
				changed = true -- 1136
				Log( -- 1137
					"Info", -- 1137
					((("[Memory] Compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1137
				) -- 1137
				round = round + 1 -- 1047
			end -- 1047
		end -- 1047
		if changed then -- 1047
			persistHistoryState(shared) -- 1140
		end -- 1140
	end) -- 1140
end -- 1043
local function compactAllHistory(shared) -- 1144
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1144
		local ____shared_14 = shared -- 1145
		local memory = ____shared_14.memory -- 1145
		local rounds = 0 -- 1146
		local totalCompressed = 0 -- 1147
		while #shared.messages > 0 do -- 1147
			if shared.stopToken.stopped then -- 1147
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1150
				return ____awaiter_resolve( -- 1150
					nil, -- 1150
					emitAgentTaskFinishEvent( -- 1151
						shared, -- 1151
						false, -- 1151
						getCancelledReason(shared) -- 1151
					) -- 1151
				) -- 1151
			end -- 1151
			local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1153
			local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1154
			rounds = rounds + 1 -- 1157
			shared.step = shared.step + 1 -- 1158
			local stepId = shared.step -- 1159
			local pendingMessages = #shared.messages -- 1160
			emitAgentEvent( -- 1161
				shared, -- 1161
				{ -- 1161
					type = "memory_compression_started", -- 1162
					sessionId = shared.sessionId, -- 1163
					taskId = shared.taskId, -- 1164
					step = stepId, -- 1165
					tool = "compress_memory", -- 1166
					reason = getMemoryCompressionStartReason(shared), -- 1167
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1168
				} -- 1168
			) -- 1168
			local result = __TS__Await(memory.compressor:compress( -- 1175
				shared.messages, -- 1176
				systemPrompt, -- 1177
				toolDefinitions, -- 1178
				shared.llmOptions, -- 1179
				shared.llmMaxTry, -- 1180
				shared.decisionMode, -- 1181
				{ -- 1182
					onInput = function(____, phase, messages, options) -- 1183
						saveStepLLMDebugInput( -- 1184
							shared, -- 1184
							stepId, -- 1184
							phase, -- 1184
							messages, -- 1184
							options -- 1184
						) -- 1184
					end, -- 1183
					onOutput = function(____, phase, text, meta) -- 1186
						saveStepLLMDebugOutput( -- 1187
							shared, -- 1187
							stepId, -- 1187
							phase, -- 1187
							text, -- 1187
							meta -- 1187
						) -- 1187
					end -- 1186
				}, -- 1186
				"budget_max" -- 1190
			)) -- 1190
			if not (result and result.success and result.compressedCount > 0) then -- 1190
				emitAgentEvent( -- 1193
					shared, -- 1193
					{ -- 1193
						type = "memory_compression_finished", -- 1194
						sessionId = shared.sessionId, -- 1195
						taskId = shared.taskId, -- 1196
						step = stepId, -- 1197
						tool = "compress_memory", -- 1198
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1199
						result = { -- 1203
							success = false, -- 1204
							rounds = rounds, -- 1205
							error = result and result.error or "compression returned no changes", -- 1206
							compressedCount = result and result.compressedCount or 0, -- 1207
							fullCompaction = true -- 1208
						} -- 1208
					} -- 1208
				) -- 1208
				return ____awaiter_resolve( -- 1208
					nil, -- 1208
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1211
				) -- 1211
			end -- 1211
			emitAgentEvent( -- 1216
				shared, -- 1216
				{ -- 1216
					type = "memory_compression_finished", -- 1217
					sessionId = shared.sessionId, -- 1218
					taskId = shared.taskId, -- 1219
					step = stepId, -- 1220
					tool = "compress_memory", -- 1221
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1222
					result = { -- 1223
						success = true, -- 1224
						round = rounds, -- 1225
						compressedCount = result.compressedCount, -- 1226
						historyEntryPreview = summarizeHistoryEntryPreview(result.historyEntry), -- 1227
						fullCompaction = true -- 1228
					} -- 1228
				} -- 1228
			) -- 1228
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessage) -- 1231
			totalCompressed = totalCompressed + result.compressedCount -- 1232
			persistHistoryState(shared) -- 1233
			Log( -- 1234
				"Info", -- 1234
				((("[Memory] Full compaction compressed " .. tostring(result.compressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1234
			) -- 1234
		end -- 1234
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1236
		return ____awaiter_resolve( -- 1236
			nil, -- 1236
			emitAgentTaskFinishEvent( -- 1237
				shared, -- 1238
				true, -- 1239
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1240
			) -- 1240
		) -- 1240
	end) -- 1240
end -- 1144
local function resetSessionHistory(shared) -- 1246
	shared.messages = {} -- 1247
	persistHistoryState(shared) -- 1248
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1249
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1250
end -- 1246
local function isKnownToolName(name) -- 1259
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "finish" -- 1260
end -- 1259
local function getFinishMessage(params, fallback) -- 1270
	if fallback == nil then -- 1270
		fallback = "" -- 1270
	end -- 1270
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1270
		return __TS__StringTrim(params.message) -- 1272
	end -- 1272
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1272
		return __TS__StringTrim(params.response) -- 1275
	end -- 1275
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1275
		return __TS__StringTrim(params.summary) -- 1278
	end -- 1278
	return __TS__StringTrim(fallback) -- 1280
end -- 1270
local function appendConversationMessage(shared, message) -- 1302
	local ____shared_messages_23 = shared.messages -- 1302
	____shared_messages_23[#____shared_messages_23 + 1] = __TS__ObjectAssign( -- 1303
		{}, -- 1303
		message, -- 1304
		{ -- 1303
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1305
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1306
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1307
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1308
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1309
		} -- 1309
	) -- 1309
end -- 1302
local function ensureToolCallId(toolCallId) -- 1313
	if toolCallId and toolCallId ~= "" then -- 1313
		return toolCallId -- 1314
	end -- 1314
	return createLocalToolCallId() -- 1315
end -- 1313
local function appendToolResultMessage(shared, action) -- 1318
	appendConversationMessage( -- 1319
		shared, -- 1319
		{ -- 1319
			role = "tool", -- 1320
			tool_call_id = action.toolCallId, -- 1321
			name = action.tool, -- 1322
			content = action.result and toJson(action.result) or "" -- 1323
		} -- 1323
	) -- 1323
end -- 1318
local function parseXMLToolCallObjectFromText(text) -- 1327
	local children = parseXMLObjectFromText(text, "tool_call") -- 1328
	if not children.success then -- 1328
		return children -- 1329
	end -- 1329
	local rawObj = children.obj -- 1330
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1331
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1332
	if not params.success then -- 1332
		return {success = false, message = params.message} -- 1336
	end -- 1336
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1338
end -- 1327
local function llm(shared, messages, phase) -- 1357
	if phase == nil then -- 1357
		phase = "decision_xml" -- 1360
	end -- 1360
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1360
		local stepId = shared.step + 1 -- 1362
		saveStepLLMDebugInput( -- 1363
			shared, -- 1363
			stepId, -- 1363
			phase, -- 1363
			messages, -- 1363
			shared.llmOptions -- 1363
		) -- 1363
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1364
		if res.success then -- 1364
			local ____opt_28 = res.response.choices -- 1364
			local ____opt_26 = ____opt_28 and ____opt_28[1] -- 1364
			local ____opt_24 = ____opt_26 and ____opt_26.message -- 1364
			local text = ____opt_24 and ____opt_24.content -- 1366
			if text then -- 1366
				saveStepLLMDebugOutput( -- 1368
					shared, -- 1368
					stepId, -- 1368
					phase, -- 1368
					text, -- 1368
					{success = true} -- 1368
				) -- 1368
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 1368
			else -- 1368
				saveStepLLMDebugOutput( -- 1371
					shared, -- 1371
					stepId, -- 1371
					phase, -- 1371
					"empty LLM response", -- 1371
					{success = false} -- 1371
				) -- 1371
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1371
			end -- 1371
		else -- 1371
			saveStepLLMDebugOutput( -- 1375
				shared, -- 1375
				stepId, -- 1375
				phase, -- 1375
				res.raw or res.message, -- 1375
				{success = false} -- 1375
			) -- 1375
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1375
		end -- 1375
	end) -- 1375
end -- 1357
local function parseDecisionObject(rawObj) -- 1392
	if type(rawObj.tool) ~= "string" then -- 1392
		return {success = false, message = "missing tool"} -- 1393
	end -- 1393
	local tool = rawObj.tool -- 1394
	if not isKnownToolName(tool) then -- 1394
		return {success = false, message = "unknown tool: " .. tool} -- 1396
	end -- 1396
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1398
	if tool ~= "finish" and (not reason or reason == "") then -- 1398
		return {success = false, message = tool .. " requires top-level reason"} -- 1402
	end -- 1402
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1404
	return {success = true, tool = tool, params = params, reason = reason} -- 1405
end -- 1392
local function parseDecisionToolCall(functionName, rawObj) -- 1413
	if not isKnownToolName(functionName) then -- 1413
		return {success = false, message = "unknown tool: " .. functionName} -- 1415
	end -- 1415
	if rawObj == nil or rawObj == nil then -- 1415
		return {success = true, tool = functionName, params = {}} -- 1418
	end -- 1418
	if not isRecord(rawObj) then -- 1418
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1421
	end -- 1421
	return {success = true, tool = functionName, params = rawObj} -- 1423
end -- 1413
local function getDecisionPath(params) -- 1430
	if type(params.path) == "string" then -- 1430
		return __TS__StringTrim(params.path) -- 1431
	end -- 1431
	if type(params.target_file) == "string" then -- 1431
		return __TS__StringTrim(params.target_file) -- 1432
	end -- 1432
	return "" -- 1433
end -- 1430
local function clampIntegerParam(value, fallback, minValue, maxValue) -- 1436
	local num = __TS__Number(value) -- 1437
	if not __TS__NumberIsFinite(num) then -- 1437
		num = fallback -- 1438
	end -- 1438
	num = math.floor(num) -- 1439
	if num < minValue then -- 1439
		num = minValue -- 1440
	end -- 1440
	if maxValue ~= nil and num > maxValue then -- 1440
		num = maxValue -- 1441
	end -- 1441
	return num -- 1442
end -- 1436
local function parseReadLineParam(value, fallback, paramName) -- 1445
	local num = __TS__Number(value) -- 1450
	if not __TS__NumberIsFinite(num) then -- 1450
		num = fallback -- 1451
	end -- 1451
	num = math.floor(num) -- 1452
	if num == 0 then -- 1452
		return {success = false, message = paramName .. " cannot be 0"} -- 1454
	end -- 1454
	return {success = true, value = num} -- 1456
end -- 1445
local function validateDecision(tool, params) -- 1459
	if tool == "finish" then -- 1459
		local message = getFinishMessage(params) -- 1464
		if message == "" then -- 1464
			return {success = false, message = "finish requires params.message"} -- 1465
		end -- 1465
		params.message = message -- 1466
		return {success = true, params = params} -- 1467
	end -- 1467
	if tool == "read_file" then -- 1467
		local path = getDecisionPath(params) -- 1471
		if path == "" then -- 1471
			return {success = false, message = "read_file requires path"} -- 1472
		end -- 1472
		params.path = path -- 1473
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1474
		if not startLineRes.success then -- 1474
			return startLineRes -- 1475
		end -- 1475
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1476
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1477
		if not endLineRes.success then -- 1477
			return endLineRes -- 1478
		end -- 1478
		params.startLine = startLineRes.value -- 1479
		params.endLine = endLineRes.value -- 1480
		return {success = true, params = params} -- 1481
	end -- 1481
	if tool == "edit_file" then -- 1481
		local path = getDecisionPath(params) -- 1485
		if path == "" then -- 1485
			return {success = false, message = "edit_file requires path"} -- 1486
		end -- 1486
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1487
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1488
		params.path = path -- 1489
		params.old_str = oldStr -- 1490
		params.new_str = newStr -- 1491
		return {success = true, params = params} -- 1492
	end -- 1492
	if tool == "delete_file" then -- 1492
		local targetFile = getDecisionPath(params) -- 1496
		if targetFile == "" then -- 1496
			return {success = false, message = "delete_file requires target_file"} -- 1497
		end -- 1497
		params.target_file = targetFile -- 1498
		return {success = true, params = params} -- 1499
	end -- 1499
	if tool == "grep_files" then -- 1499
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1503
		if pattern == "" then -- 1503
			return {success = false, message = "grep_files requires pattern"} -- 1504
		end -- 1504
		params.pattern = pattern -- 1505
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1506
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1507
		return {success = true, params = params} -- 1508
	end -- 1508
	if tool == "search_dora_api" then -- 1508
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1512
		if pattern == "" then -- 1512
			return {success = false, message = "search_dora_api requires pattern"} -- 1513
		end -- 1513
		params.pattern = pattern -- 1514
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1515
		return {success = true, params = params} -- 1516
	end -- 1516
	if tool == "glob_files" then -- 1516
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1520
		return {success = true, params = params} -- 1521
	end -- 1521
	if tool == "build" then -- 1521
		local path = getDecisionPath(params) -- 1525
		if path ~= "" then -- 1525
			params.path = path -- 1527
		end -- 1527
		return {success = true, params = params} -- 1529
	end -- 1529
	return {success = true, params = params} -- 1532
end -- 1459
local function createFunctionToolSchema(name, description, properties, required) -- 1535
	if required == nil then -- 1535
		required = {} -- 1539
	end -- 1539
	local parameters = {type = "object", properties = properties} -- 1541
	if #required > 0 then -- 1541
		parameters.required = required -- 1546
	end -- 1546
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1548
end -- 1535
local function buildDecisionToolSchema() -- 1558
	return { -- 1559
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1560
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If the file does not exist, set old_str to empty string to create it with new_str.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. Use an empty string only when creating a new file."}, new_str = {type = "string", description = "Replacement text or the full new file content when creating."}}, {"path", "old_str", "new_str"}), -- 1570
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1580
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1588
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1592
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1593
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1594
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1595
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1596
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1597
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1598
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1599
		}, {"pattern"}), -- 1599
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1603
		createFunctionToolSchema( -- 1612
			"search_dora_api", -- 1613
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1613
			{ -- 1615
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1616
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1617
				programmingLanguage = {type = "string", enum = { -- 1618
					"ts", -- 1620
					"tsx", -- 1620
					"lua", -- 1620
					"yue", -- 1620
					"teal", -- 1620
					"tl", -- 1620
					"wa" -- 1620
				}, description = "Preferred language variant to search."}, -- 1620
				limit = { -- 1623
					type = "number", -- 1623
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1623
				}, -- 1623
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1624
			}, -- 1624
			{"pattern"} -- 1626
		), -- 1626
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}) -- 1628
	} -- 1628
end -- 1558
local function sanitizeMessagesForLLMInput(messages) -- 1668
	local sanitized = {} -- 1669
	local droppedAssistantToolCalls = 0 -- 1670
	local droppedToolResults = 0 -- 1671
	do -- 1671
		local i = 0 -- 1672
		while i < #messages do -- 1672
			do -- 1672
				local message = messages[i + 1] -- 1673
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1673
					local requiredIds = {} -- 1675
					do -- 1675
						local j = 0 -- 1676
						while j < #message.tool_calls do -- 1676
							local toolCall = message.tool_calls[j + 1] -- 1677
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1678
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1678
								requiredIds[#requiredIds + 1] = id -- 1680
							end -- 1680
							j = j + 1 -- 1676
						end -- 1676
					end -- 1676
					if #requiredIds == 0 then -- 1676
						sanitized[#sanitized + 1] = message -- 1684
						goto __continue266 -- 1685
					end -- 1685
					local matchedIds = {} -- 1687
					local matchedTools = {} -- 1688
					local j = i + 1 -- 1689
					while j < #messages do -- 1689
						local toolMessage = messages[j + 1] -- 1691
						if toolMessage.role ~= "tool" then -- 1691
							break -- 1692
						end -- 1692
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1693
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1693
							matchedIds[toolCallId] = true -- 1695
							matchedTools[#matchedTools + 1] = toolMessage -- 1696
						else -- 1696
							droppedToolResults = droppedToolResults + 1 -- 1698
						end -- 1698
						j = j + 1 -- 1700
					end -- 1700
					local complete = true -- 1702
					do -- 1702
						local j = 0 -- 1703
						while j < #requiredIds do -- 1703
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1703
								complete = false -- 1705
								break -- 1706
							end -- 1706
							j = j + 1 -- 1703
						end -- 1703
					end -- 1703
					if complete then -- 1703
						__TS__ArrayPush( -- 1710
							sanitized, -- 1710
							message, -- 1710
							table.unpack(matchedTools) -- 1710
						) -- 1710
					else -- 1710
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1712
						droppedToolResults = droppedToolResults + #matchedTools -- 1713
					end -- 1713
					i = j - 1 -- 1715
					goto __continue266 -- 1716
				end -- 1716
				if message.role == "tool" then -- 1716
					droppedToolResults = droppedToolResults + 1 -- 1719
					goto __continue266 -- 1720
				end -- 1720
				sanitized[#sanitized + 1] = message -- 1722
			end -- 1722
			::__continue266:: -- 1722
			i = i + 1 -- 1672
		end -- 1672
	end -- 1672
	return sanitized -- 1724
end -- 1668
local function getUnconsolidatedMessages(shared) -- 1727
	return sanitizeMessagesForLLMInput(shared.messages) -- 1728
end -- 1727
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1731
	if attempt == nil then -- 1731
		attempt = 1 -- 1731
	end -- 1731
	local messages = { -- 1732
		{ -- 1733
			role = "system", -- 1733
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1733
		}, -- 1733
		table.unpack(getUnconsolidatedMessages(shared)) -- 1734
	} -- 1734
	if lastError and lastError ~= "" then -- 1734
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1737
		messages[#messages + 1] = { -- 1740
			role = "user", -- 1741
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1742
		} -- 1742
	end -- 1742
	return messages -- 1749
end -- 1731
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 1756
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 1763
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 1764
	local repairPrompt = replacePromptVars( -- 1772
		shared.promptPack.xmlDecisionRepairPrompt, -- 1772
		{ -- 1772
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 1773
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 1774
			CANDIDATE_SECTION = candidateSection, -- 1775
			LAST_ERROR = lastError, -- 1776
			ATTEMPT = tostring(attempt) -- 1777
		} -- 1777
	) -- 1777
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 1779
end -- 1756
local function tryParseAndValidateDecision(rawText) -- 1791
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 1792
	if not parsed.success then -- 1792
		return {success = false, message = parsed.message, raw = rawText} -- 1794
	end -- 1794
	local decision = parseDecisionObject(parsed.obj) -- 1796
	if not decision.success then -- 1796
		return {success = false, message = decision.message, raw = rawText} -- 1798
	end -- 1798
	local validation = validateDecision(decision.tool, decision.params) -- 1800
	if not validation.success then -- 1800
		return {success = false, message = validation.message, raw = rawText} -- 1802
	end -- 1802
	decision.params = validation.params -- 1804
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 1805
	return decision -- 1806
end -- 1791
local function normalizeLineEndings(text) -- 1809
	local res = string.gsub(text, "\r\n", "\n") -- 1810
	res = string.gsub(res, "\r", "\n") -- 1811
	return res -- 1812
end -- 1809
local function countOccurrences(text, searchStr) -- 1815
	if searchStr == "" then -- 1815
		return 0 -- 1816
	end -- 1816
	local count = 0 -- 1817
	local pos = 0 -- 1818
	while true do -- 1818
		local idx = (string.find( -- 1820
			text, -- 1820
			searchStr, -- 1820
			math.max(pos + 1, 1), -- 1820
			true -- 1820
		) or 0) - 1 -- 1820
		if idx < 0 then -- 1820
			break -- 1821
		end -- 1821
		count = count + 1 -- 1822
		pos = idx + #searchStr -- 1823
	end -- 1823
	return count -- 1825
end -- 1815
local function replaceFirst(text, oldStr, newStr) -- 1828
	if oldStr == "" then -- 1828
		return text -- 1829
	end -- 1829
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 1830
	if idx < 0 then -- 1830
		return text -- 1831
	end -- 1831
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 1832
end -- 1828
local function splitLines(text) -- 1835
	return __TS__StringSplit(text, "\n") -- 1836
end -- 1835
local function getLeadingWhitespace(text) -- 1839
	local i = 0 -- 1840
	while i < #text do -- 1840
		local ch = __TS__StringAccess(text, i) -- 1842
		if ch ~= " " and ch ~= "\t" then -- 1842
			break -- 1843
		end -- 1843
		i = i + 1 -- 1844
	end -- 1844
	return __TS__StringSubstring(text, 0, i) -- 1846
end -- 1839
local function getCommonIndentPrefix(lines) -- 1849
	local common -- 1850
	do -- 1850
		local i = 0 -- 1851
		while i < #lines do -- 1851
			do -- 1851
				local line = lines[i + 1] -- 1852
				if __TS__StringTrim(line) == "" then -- 1852
					goto __continue305 -- 1853
				end -- 1853
				local indent = getLeadingWhitespace(line) -- 1854
				if common == nil then -- 1854
					common = indent -- 1856
					goto __continue305 -- 1857
				end -- 1857
				local j = 0 -- 1859
				local maxLen = math.min(#common, #indent) -- 1860
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 1860
					j = j + 1 -- 1862
				end -- 1862
				common = __TS__StringSubstring(common, 0, j) -- 1864
				if common == "" then -- 1864
					break -- 1865
				end -- 1865
			end -- 1865
			::__continue305:: -- 1865
			i = i + 1 -- 1851
		end -- 1851
	end -- 1851
	return common or "" -- 1867
end -- 1849
local function removeIndentPrefix(line, indent) -- 1870
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 1870
		return __TS__StringSubstring(line, #indent) -- 1872
	end -- 1872
	local lineIndent = getLeadingWhitespace(line) -- 1874
	local j = 0 -- 1875
	local maxLen = math.min(#lineIndent, #indent) -- 1876
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 1876
		j = j + 1 -- 1878
	end -- 1878
	return __TS__StringSubstring(line, j) -- 1880
end -- 1870
local function dedentLines(lines) -- 1883
	local indent = getCommonIndentPrefix(lines) -- 1884
	return { -- 1885
		indent = indent, -- 1886
		lines = __TS__ArrayMap( -- 1887
			lines, -- 1887
			function(____, line) return removeIndentPrefix(line, indent) end -- 1887
		) -- 1887
	} -- 1887
end -- 1883
local function joinLines(lines) -- 1891
	return table.concat(lines, "\n") -- 1892
end -- 1891
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 1895
	local contentLines = splitLines(content) -- 1900
	local oldLines = splitLines(oldStr) -- 1901
	if #oldLines == 0 then -- 1901
		return {success = false, message = "old_str not found in file"} -- 1903
	end -- 1903
	local dedentedOld = dedentLines(oldLines) -- 1905
	local dedentedOldText = joinLines(dedentedOld.lines) -- 1906
	local dedentedNew = dedentLines(splitLines(newStr)) -- 1907
	local matches = {} -- 1908
	do -- 1908
		local start = 0 -- 1909
		while start <= #contentLines - #oldLines do -- 1909
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 1910
			local dedentedCandidate = dedentLines(candidateLines) -- 1911
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 1911
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 1913
			end -- 1913
			start = start + 1 -- 1909
		end -- 1909
	end -- 1909
	if #matches == 0 then -- 1909
		return {success = false, message = "old_str not found in file"} -- 1921
	end -- 1921
	if #matches > 1 then -- 1921
		return { -- 1924
			success = false, -- 1925
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 1926
		} -- 1926
	end -- 1926
	local match = matches[1] -- 1929
	local rebuiltNewLines = __TS__ArrayMap( -- 1930
		dedentedNew.lines, -- 1930
		function(____, line) return line == "" and "" or match.indent .. line end -- 1930
	) -- 1930
	local ____array_34 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 1930
	__TS__SparseArrayPush( -- 1930
		____array_34, -- 1930
		table.unpack(rebuiltNewLines) -- 1933
	) -- 1933
	__TS__SparseArrayPush( -- 1933
		____array_34, -- 1933
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 1934
	) -- 1934
	local nextLines = {__TS__SparseArraySpread(____array_34)} -- 1931
	return { -- 1936
		success = true, -- 1936
		content = joinLines(nextLines) -- 1936
	} -- 1936
end -- 1895
local MainDecisionAgent = __TS__Class() -- 1939
MainDecisionAgent.name = "MainDecisionAgent" -- 1939
__TS__ClassExtends(MainDecisionAgent, Node) -- 1939
function MainDecisionAgent.prototype.prep(self, shared) -- 1940
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1940
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 1940
			return ____awaiter_resolve(nil, {shared = shared}) -- 1940
		end -- 1940
		__TS__Await(maybeCompressHistory(shared)) -- 1945
		return ____awaiter_resolve(nil, {shared = shared}) -- 1945
	end) -- 1945
end -- 1940
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 1950
	if attempt == nil then -- 1950
		attempt = 1 -- 1953
	end -- 1953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1953
		if shared.stopToken.stopped then -- 1953
			return ____awaiter_resolve( -- 1953
				nil, -- 1953
				{ -- 1957
					success = false, -- 1957
					message = getCancelledReason(shared) -- 1957
				} -- 1957
			) -- 1957
		end -- 1957
		Log( -- 1959
			"Info", -- 1959
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 1959
		) -- 1959
		local tools = buildDecisionToolSchema() -- 1960
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 1961
		local stepId = shared.step + 1 -- 1962
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 1963
		saveStepLLMDebugInput( -- 1967
			shared, -- 1967
			stepId, -- 1967
			"decision_tool_calling", -- 1967
			messages, -- 1967
			llmOptions -- 1967
		) -- 1967
		local lastStreamContent = "" -- 1968
		local lastStreamReasoning = "" -- 1969
		local res = __TS__Await(callLLMStreamAggregated( -- 1970
			messages, -- 1971
			llmOptions, -- 1972
			shared.stopToken, -- 1973
			shared.llmConfig, -- 1974
			function(response) -- 1975
				local ____opt_37 = response.choices -- 1975
				local ____opt_35 = ____opt_37 and ____opt_37[1] -- 1975
				local streamMessage = ____opt_35 and ____opt_35.message -- 1976
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1977
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 1980
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 1980
					return -- 1984
				end -- 1984
				lastStreamContent = nextContent -- 1986
				lastStreamReasoning = nextReasoning -- 1987
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 1988
			end -- 1975
		)) -- 1975
		if shared.stopToken.stopped then -- 1975
			return ____awaiter_resolve( -- 1975
				nil, -- 1975
				{ -- 1992
					success = false, -- 1992
					message = getCancelledReason(shared) -- 1992
				} -- 1992
			) -- 1992
		end -- 1992
		if not res.success then -- 1992
			saveStepLLMDebugOutput( -- 1995
				shared, -- 1995
				stepId, -- 1995
				"decision_tool_calling", -- 1995
				res.raw or res.message, -- 1995
				{success = false} -- 1995
			) -- 1995
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 1996
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 1996
		end -- 1996
		saveStepLLMDebugOutput( -- 1999
			shared, -- 1999
			stepId, -- 1999
			"decision_tool_calling", -- 1999
			encodeDebugJSON(res.response), -- 1999
			{success = true} -- 1999
		) -- 1999
		local choice = res.response.choices and res.response.choices[1] -- 2000
		local message = choice and choice.message -- 2001
		local toolCalls = message and message.tool_calls -- 2002
		local toolCall = toolCalls and toolCalls[1] -- 2003
		local fn = toolCall and toolCall["function"] -- 2004
		local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2005
		local reasoningContent = message and type(message.reasoning_content) == "string" and __TS__StringTrim(message.reasoning_content) or nil -- 2008
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2011
		Log( -- 2014
			"Info", -- 2014
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2014
		) -- 2014
		if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2014
			if messageContent and messageContent ~= "" then -- 2014
				Log( -- 2017
					"Info", -- 2017
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2017
				) -- 2017
				return ____awaiter_resolve(nil, { -- 2017
					success = true, -- 2019
					tool = "finish", -- 2020
					params = {}, -- 2021
					reason = messageContent, -- 2022
					reasoningContent = reasoningContent, -- 2023
					directSummary = messageContent -- 2024
				}) -- 2024
			end -- 2024
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2027
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2027
		end -- 2027
		local functionName = fn.name -- 2034
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2035
		Log( -- 2036
			"Info", -- 2036
			(("[CodingAgent] tool-calling function=" .. functionName) .. " args_len=") .. tostring(#argsText) -- 2036
		) -- 2036
		local rawArgs = __TS__StringTrim(argsText) == "" and ({}) or (function() -- 2037
			local rawObj, err = safeJsonDecode(argsText) -- 2038
			if err ~= nil or rawObj == nil then -- 2038
				return {__error = tostring(err)} -- 2040
			end -- 2040
			return rawObj -- 2042
		end)() -- 2037
		if isRecord(rawArgs) and rawArgs.__error ~= nil then -- 2037
			local err = tostring(rawArgs.__error) -- 2045
			Log("Error", (("[CodingAgent] invalid " .. functionName) .. " arguments JSON: ") .. err) -- 2046
			return ____awaiter_resolve(nil, {success = false, message = (("invalid " .. functionName) .. " arguments: ") .. err, raw = argsText}) -- 2046
		end -- 2046
		local decision = parseDecisionToolCall(functionName, rawArgs) -- 2053
		if not decision.success then -- 2053
			Log("Error", "[CodingAgent] invalid tool arguments schema: " .. decision.message) -- 2055
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 2055
		end -- 2055
		local validation = validateDecision(decision.tool, decision.params) -- 2062
		if not validation.success then -- 2062
			Log("Error", (("[CodingAgent] invalid " .. decision.tool) .. " arguments values: ") .. validation.message) -- 2064
			return ____awaiter_resolve(nil, {success = false, message = validation.message, raw = argsText}) -- 2064
		end -- 2064
		decision.params = validation.params -- 2071
		decision.toolCallId = ensureToolCallId(toolCallId) -- 2072
		decision.reason = messageContent -- 2073
		decision.reasoningContent = reasoningContent -- 2074
		Log("Info", "[CodingAgent] tool-calling selected tool=" .. decision.tool) -- 2075
		return ____awaiter_resolve(nil, decision) -- 2075
	end) -- 2075
end -- 1950
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2079
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2079
		Log( -- 2084
			"Info", -- 2084
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2084
		) -- 2084
		local lastError = initialError -- 2085
		local candidateRaw = "" -- 2086
		do -- 2086
			local attempt = 0 -- 2087
			while attempt < shared.llmMaxTry do -- 2087
				do -- 2087
					Log( -- 2088
						"Info", -- 2088
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2088
					) -- 2088
					local messages = buildXmlRepairMessages( -- 2089
						shared, -- 2090
						originalRaw, -- 2091
						candidateRaw, -- 2092
						lastError, -- 2093
						attempt + 1 -- 2094
					) -- 2094
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2096
					if shared.stopToken.stopped then -- 2096
						return ____awaiter_resolve( -- 2096
							nil, -- 2096
							{ -- 2098
								success = false, -- 2098
								message = getCancelledReason(shared) -- 2098
							} -- 2098
						) -- 2098
					end -- 2098
					if not llmRes.success then -- 2098
						lastError = llmRes.message -- 2101
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2102
						goto __continue341 -- 2103
					end -- 2103
					candidateRaw = llmRes.text -- 2105
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2106
					if decision.success then -- 2106
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2108
						return ____awaiter_resolve(nil, decision) -- 2108
					end -- 2108
					lastError = decision.message -- 2111
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2112
				end -- 2112
				::__continue341:: -- 2112
				attempt = attempt + 1 -- 2087
			end -- 2087
		end -- 2087
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2114
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2114
	end) -- 2114
end -- 2079
function MainDecisionAgent.prototype.exec(self, input) -- 2122
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2122
		local shared = input.shared -- 2123
		if shared.stopToken.stopped then -- 2123
			return ____awaiter_resolve( -- 2123
				nil, -- 2123
				{ -- 2125
					success = false, -- 2125
					message = getCancelledReason(shared) -- 2125
				} -- 2125
			) -- 2125
		end -- 2125
		if shared.step >= shared.maxSteps then -- 2125
			Log( -- 2128
				"Warn", -- 2128
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2128
			) -- 2128
			return ____awaiter_resolve( -- 2128
				nil, -- 2128
				{ -- 2129
					success = false, -- 2129
					message = getMaxStepsReachedReason(shared) -- 2129
				} -- 2129
			) -- 2129
		end -- 2129
		if shared.decisionMode == "tool_calling" then -- 2129
			Log( -- 2133
				"Info", -- 2133
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2133
			) -- 2133
			local lastError = "tool calling validation failed" -- 2134
			local lastRaw = "" -- 2135
			do -- 2135
				local attempt = 0 -- 2136
				while attempt < shared.llmMaxTry do -- 2136
					Log( -- 2137
						"Info", -- 2137
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2137
					) -- 2137
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2138
					if shared.stopToken.stopped then -- 2138
						return ____awaiter_resolve( -- 2138
							nil, -- 2138
							{ -- 2145
								success = false, -- 2145
								message = getCancelledReason(shared) -- 2145
							} -- 2145
						) -- 2145
					end -- 2145
					if decision.success then -- 2145
						return ____awaiter_resolve(nil, decision) -- 2145
					end -- 2145
					lastError = decision.message -- 2150
					lastRaw = decision.raw or "" -- 2151
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2152
					attempt = attempt + 1 -- 2136
				end -- 2136
			end -- 2136
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2154
			return ____awaiter_resolve( -- 2154
				nil, -- 2154
				{ -- 2155
					success = false, -- 2155
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2155
				} -- 2155
			) -- 2155
		end -- 2155
		local lastError = "xml validation failed" -- 2158
		local lastRaw = "" -- 2159
		do -- 2159
			local attempt = 0 -- 2160
			while attempt < shared.llmMaxTry do -- 2160
				do -- 2160
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2161
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2169
					if shared.stopToken.stopped then -- 2169
						return ____awaiter_resolve( -- 2169
							nil, -- 2169
							{ -- 2171
								success = false, -- 2171
								message = getCancelledReason(shared) -- 2171
							} -- 2171
						) -- 2171
					end -- 2171
					if not llmRes.success then -- 2171
						lastError = llmRes.message -- 2174
						lastRaw = llmRes.text or "" -- 2175
						goto __continue354 -- 2176
					end -- 2176
					lastRaw = llmRes.text -- 2178
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2179
					if decision.success then -- 2179
						return ____awaiter_resolve(nil, decision) -- 2179
					end -- 2179
					lastError = decision.message -- 2183
					return ____awaiter_resolve( -- 2183
						nil, -- 2183
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2184
					) -- 2184
				end -- 2184
				::__continue354:: -- 2184
				attempt = attempt + 1 -- 2160
			end -- 2160
		end -- 2160
		return ____awaiter_resolve( -- 2160
			nil, -- 2160
			{ -- 2186
				success = false, -- 2186
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2186
			} -- 2186
		) -- 2186
	end) -- 2186
end -- 2122
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2189
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2189
		local result = execRes -- 2190
		if not result.success then -- 2190
			if shared.stopToken.stopped then -- 2190
				shared.error = getCancelledReason(shared) -- 2193
				shared.done = true -- 2194
				return ____awaiter_resolve(nil, "done") -- 2194
			end -- 2194
			shared.error = result.message -- 2197
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2198
			shared.done = true -- 2199
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2200
			persistHistoryState(shared) -- 2204
			return ____awaiter_resolve(nil, "done") -- 2204
		end -- 2204
		if result.directSummary and result.directSummary ~= "" then -- 2204
			shared.response = result.directSummary -- 2208
			shared.done = true -- 2209
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2210
			persistHistoryState(shared) -- 2215
			return ____awaiter_resolve(nil, "done") -- 2215
		end -- 2215
		if result.tool == "finish" then -- 2215
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2219
			shared.response = finalMessage -- 2220
			shared.done = true -- 2221
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2222
			persistHistoryState(shared) -- 2227
			return ____awaiter_resolve(nil, "done") -- 2227
		end -- 2227
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2230
		shared.step = shared.step + 1 -- 2231
		local step = shared.step -- 2232
		emitAgentEvent(shared, { -- 2233
			type = "decision_made", -- 2234
			sessionId = shared.sessionId, -- 2235
			taskId = shared.taskId, -- 2236
			step = step, -- 2237
			tool = result.tool, -- 2238
			reason = result.reason, -- 2239
			reasoningContent = result.reasoningContent, -- 2240
			params = result.params -- 2241
		}) -- 2241
		local ____shared_history_43 = shared.history -- 2241
		____shared_history_43[#____shared_history_43 + 1] = { -- 2243
			step = step, -- 2244
			toolCallId = toolCallId, -- 2245
			tool = result.tool, -- 2246
			reason = result.reason or "", -- 2247
			reasoningContent = result.reasoningContent, -- 2248
			params = result.params, -- 2249
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2250
		} -- 2250
		appendConversationMessage( -- 2252
			shared, -- 2252
			{ -- 2252
				role = "assistant", -- 2253
				content = result.reason or "", -- 2254
				reasoning_content = result.reasoningContent, -- 2255
				tool_calls = {{ -- 2256
					id = toolCallId, -- 2257
					type = "function", -- 2258
					["function"] = { -- 2259
						name = result.tool, -- 2260
						arguments = toJson(result.params) -- 2261
					} -- 2261
				}} -- 2261
			} -- 2261
		) -- 2261
		persistHistoryState(shared) -- 2265
		return ____awaiter_resolve(nil, result.tool) -- 2265
	end) -- 2265
end -- 2189
local ReadFileAction = __TS__Class() -- 2270
ReadFileAction.name = "ReadFileAction" -- 2270
__TS__ClassExtends(ReadFileAction, Node) -- 2270
function ReadFileAction.prototype.prep(self, shared) -- 2271
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2271
		local last = shared.history[#shared.history] -- 2272
		if not last then -- 2272
			error( -- 2273
				__TS__New(Error, "no history"), -- 2273
				0 -- 2273
			) -- 2273
		end -- 2273
		emitAgentStartEvent(shared, last) -- 2274
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2275
		if __TS__StringTrim(path) == "" then -- 2275
			error( -- 2278
				__TS__New(Error, "missing path"), -- 2278
				0 -- 2278
			) -- 2278
		end -- 2278
		local ____path_46 = path -- 2280
		local ____shared_workingDir_47 = shared.workingDir -- 2282
		local ____temp_48 = shared.useChineseResponse and "zh" or "en" -- 2283
		local ____last_params_startLine_44 = last.params.startLine -- 2284
		if ____last_params_startLine_44 == nil then -- 2284
			____last_params_startLine_44 = 1 -- 2284
		end -- 2284
		local ____TS__Number_result_49 = __TS__Number(____last_params_startLine_44) -- 2284
		local ____last_params_endLine_45 = last.params.endLine -- 2285
		if ____last_params_endLine_45 == nil then -- 2285
			____last_params_endLine_45 = READ_FILE_DEFAULT_LIMIT -- 2285
		end -- 2285
		return ____awaiter_resolve( -- 2285
			nil, -- 2285
			{ -- 2279
				path = ____path_46, -- 2280
				tool = "read_file", -- 2281
				workDir = ____shared_workingDir_47, -- 2282
				docLanguage = ____temp_48, -- 2283
				startLine = ____TS__Number_result_49, -- 2284
				endLine = __TS__Number(____last_params_endLine_45) -- 2285
			} -- 2285
		) -- 2285
	end) -- 2285
end -- 2271
function ReadFileAction.prototype.exec(self, input) -- 2289
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2289
		return ____awaiter_resolve( -- 2289
			nil, -- 2289
			Tools.readFile( -- 2290
				input.workDir, -- 2291
				input.path, -- 2292
				__TS__Number(input.startLine or 1), -- 2293
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2294
				input.docLanguage -- 2295
			) -- 2295
		) -- 2295
	end) -- 2295
end -- 2289
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2299
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2299
		local result = execRes -- 2300
		local last = shared.history[#shared.history] -- 2301
		if last ~= nil then -- 2301
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2303
			appendToolResultMessage(shared, last) -- 2304
			emitAgentFinishEvent(shared, last) -- 2305
		end -- 2305
		persistHistoryState(shared) -- 2307
		__TS__Await(maybeCompressHistory(shared)) -- 2308
		persistHistoryState(shared) -- 2309
		return ____awaiter_resolve(nil, "main") -- 2309
	end) -- 2309
end -- 2299
local SearchFilesAction = __TS__Class() -- 2314
SearchFilesAction.name = "SearchFilesAction" -- 2314
__TS__ClassExtends(SearchFilesAction, Node) -- 2314
function SearchFilesAction.prototype.prep(self, shared) -- 2315
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2315
		local last = shared.history[#shared.history] -- 2316
		if not last then -- 2316
			error( -- 2317
				__TS__New(Error, "no history"), -- 2317
				0 -- 2317
			) -- 2317
		end -- 2317
		emitAgentStartEvent(shared, last) -- 2318
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2318
	end) -- 2318
end -- 2315
function SearchFilesAction.prototype.exec(self, input) -- 2322
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2322
		local params = input.params -- 2323
		local ____Tools_searchFiles_63 = Tools.searchFiles -- 2324
		local ____input_workDir_56 = input.workDir -- 2325
		local ____temp_57 = params.path or "" -- 2326
		local ____temp_58 = params.pattern or "" -- 2327
		local ____params_globs_59 = params.globs -- 2328
		local ____params_useRegex_60 = params.useRegex -- 2329
		local ____params_caseSensitive_61 = params.caseSensitive -- 2330
		local ____math_max_52 = math.max -- 2333
		local ____math_floor_51 = math.floor -- 2333
		local ____params_limit_50 = params.limit -- 2333
		if ____params_limit_50 == nil then -- 2333
			____params_limit_50 = SEARCH_FILES_LIMIT_DEFAULT -- 2333
		end -- 2333
		local ____math_max_52_result_62 = ____math_max_52( -- 2333
			1, -- 2333
			____math_floor_51(__TS__Number(____params_limit_50)) -- 2333
		) -- 2333
		local ____math_max_55 = math.max -- 2334
		local ____math_floor_54 = math.floor -- 2334
		local ____params_offset_53 = params.offset -- 2334
		if ____params_offset_53 == nil then -- 2334
			____params_offset_53 = 0 -- 2334
		end -- 2334
		local result = __TS__Await(____Tools_searchFiles_63({ -- 2324
			workDir = ____input_workDir_56, -- 2325
			path = ____temp_57, -- 2326
			pattern = ____temp_58, -- 2327
			globs = ____params_globs_59, -- 2328
			useRegex = ____params_useRegex_60, -- 2329
			caseSensitive = ____params_caseSensitive_61, -- 2330
			includeContent = true, -- 2331
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2332
			limit = ____math_max_52_result_62, -- 2333
			offset = ____math_max_55( -- 2334
				0, -- 2334
				____math_floor_54(__TS__Number(____params_offset_53)) -- 2334
			), -- 2334
			groupByFile = params.groupByFile == true -- 2335
		})) -- 2335
		return ____awaiter_resolve(nil, result) -- 2335
	end) -- 2335
end -- 2322
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2340
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2340
		local last = shared.history[#shared.history] -- 2341
		if last ~= nil then -- 2341
			local result = execRes -- 2343
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2344
			appendToolResultMessage(shared, last) -- 2345
			emitAgentFinishEvent(shared, last) -- 2346
		end -- 2346
		persistHistoryState(shared) -- 2348
		__TS__Await(maybeCompressHistory(shared)) -- 2349
		persistHistoryState(shared) -- 2350
		return ____awaiter_resolve(nil, "main") -- 2350
	end) -- 2350
end -- 2340
local SearchDoraAPIAction = __TS__Class() -- 2355
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2355
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2355
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2356
		local last = shared.history[#shared.history] -- 2357
		if not last then -- 2357
			error( -- 2358
				__TS__New(Error, "no history"), -- 2358
				0 -- 2358
			) -- 2358
		end -- 2358
		emitAgentStartEvent(shared, last) -- 2359
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2359
	end) -- 2359
end -- 2356
function SearchDoraAPIAction.prototype.exec(self, input) -- 2363
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2363
		local params = input.params -- 2364
		local ____Tools_searchDoraAPI_71 = Tools.searchDoraAPI -- 2365
		local ____temp_67 = params.pattern or "" -- 2366
		local ____temp_68 = params.docSource or "api" -- 2367
		local ____temp_69 = input.useChineseResponse and "zh" or "en" -- 2368
		local ____temp_70 = params.programmingLanguage or "ts" -- 2369
		local ____math_min_66 = math.min -- 2370
		local ____math_max_65 = math.max -- 2370
		local ____params_limit_64 = params.limit -- 2370
		if ____params_limit_64 == nil then -- 2370
			____params_limit_64 = 8 -- 2370
		end -- 2370
		local result = __TS__Await(____Tools_searchDoraAPI_71({ -- 2365
			pattern = ____temp_67, -- 2366
			docSource = ____temp_68, -- 2367
			docLanguage = ____temp_69, -- 2368
			programmingLanguage = ____temp_70, -- 2369
			limit = ____math_min_66( -- 2370
				SEARCH_DORA_API_LIMIT_MAX, -- 2370
				____math_max_65( -- 2370
					1, -- 2370
					__TS__Number(____params_limit_64) -- 2370
				) -- 2370
			), -- 2370
			useRegex = params.useRegex, -- 2371
			caseSensitive = false, -- 2372
			includeContent = true, -- 2373
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2374
		})) -- 2374
		return ____awaiter_resolve(nil, result) -- 2374
	end) -- 2374
end -- 2363
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2379
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2379
		local last = shared.history[#shared.history] -- 2380
		if last ~= nil then -- 2380
			local result = execRes -- 2382
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2383
			appendToolResultMessage(shared, last) -- 2384
			emitAgentFinishEvent(shared, last) -- 2385
		end -- 2385
		persistHistoryState(shared) -- 2387
		__TS__Await(maybeCompressHistory(shared)) -- 2388
		persistHistoryState(shared) -- 2389
		return ____awaiter_resolve(nil, "main") -- 2389
	end) -- 2389
end -- 2379
local ListFilesAction = __TS__Class() -- 2394
ListFilesAction.name = "ListFilesAction" -- 2394
__TS__ClassExtends(ListFilesAction, Node) -- 2394
function ListFilesAction.prototype.prep(self, shared) -- 2395
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2395
		local last = shared.history[#shared.history] -- 2396
		if not last then -- 2396
			error( -- 2397
				__TS__New(Error, "no history"), -- 2397
				0 -- 2397
			) -- 2397
		end -- 2397
		emitAgentStartEvent(shared, last) -- 2398
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2398
	end) -- 2398
end -- 2395
function ListFilesAction.prototype.exec(self, input) -- 2402
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2402
		local params = input.params -- 2403
		local ____Tools_listFiles_78 = Tools.listFiles -- 2404
		local ____input_workDir_75 = input.workDir -- 2405
		local ____temp_76 = params.path or "" -- 2406
		local ____params_globs_77 = params.globs -- 2407
		local ____math_max_74 = math.max -- 2408
		local ____math_floor_73 = math.floor -- 2408
		local ____params_maxEntries_72 = params.maxEntries -- 2408
		if ____params_maxEntries_72 == nil then -- 2408
			____params_maxEntries_72 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2408
		end -- 2408
		local result = ____Tools_listFiles_78({ -- 2404
			workDir = ____input_workDir_75, -- 2405
			path = ____temp_76, -- 2406
			globs = ____params_globs_77, -- 2407
			maxEntries = ____math_max_74( -- 2408
				1, -- 2408
				____math_floor_73(__TS__Number(____params_maxEntries_72)) -- 2408
			) -- 2408
		}) -- 2408
		return ____awaiter_resolve(nil, result) -- 2408
	end) -- 2408
end -- 2402
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2413
		local last = shared.history[#shared.history] -- 2414
		if last ~= nil then -- 2414
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2416
			appendToolResultMessage(shared, last) -- 2417
			emitAgentFinishEvent(shared, last) -- 2418
		end -- 2418
		persistHistoryState(shared) -- 2420
		__TS__Await(maybeCompressHistory(shared)) -- 2421
		persistHistoryState(shared) -- 2422
		return ____awaiter_resolve(nil, "main") -- 2422
	end) -- 2422
end -- 2413
local DeleteFileAction = __TS__Class() -- 2427
DeleteFileAction.name = "DeleteFileAction" -- 2427
__TS__ClassExtends(DeleteFileAction, Node) -- 2427
function DeleteFileAction.prototype.prep(self, shared) -- 2428
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2428
		local last = shared.history[#shared.history] -- 2429
		if not last then -- 2429
			error( -- 2430
				__TS__New(Error, "no history"), -- 2430
				0 -- 2430
			) -- 2430
		end -- 2430
		emitAgentStartEvent(shared, last) -- 2431
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2432
		if __TS__StringTrim(targetFile) == "" then -- 2432
			error( -- 2435
				__TS__New(Error, "missing target_file"), -- 2435
				0 -- 2435
			) -- 2435
		end -- 2435
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2435
	end) -- 2435
end -- 2428
function DeleteFileAction.prototype.exec(self, input) -- 2439
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2439
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2440
		if not result.success then -- 2440
			return ____awaiter_resolve(nil, result) -- 2440
		end -- 2440
		return ____awaiter_resolve(nil, { -- 2440
			success = true, -- 2448
			changed = true, -- 2449
			mode = "delete", -- 2450
			checkpointId = result.checkpointId, -- 2451
			checkpointSeq = result.checkpointSeq, -- 2452
			files = {{path = input.targetFile, op = "delete"}} -- 2453
		}) -- 2453
	end) -- 2453
end -- 2439
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2457
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2457
		local last = shared.history[#shared.history] -- 2458
		if last ~= nil then -- 2458
			last.result = execRes -- 2460
			appendToolResultMessage(shared, last) -- 2461
			emitAgentFinishEvent(shared, last) -- 2462
			local result = last.result -- 2463
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2463
				emitAgentEvent(shared, { -- 2468
					type = "checkpoint_created", -- 2469
					sessionId = shared.sessionId, -- 2470
					taskId = shared.taskId, -- 2471
					step = last.step, -- 2472
					tool = "delete_file", -- 2473
					checkpointId = result.checkpointId, -- 2474
					checkpointSeq = result.checkpointSeq, -- 2475
					files = result.files -- 2476
				}) -- 2476
			end -- 2476
		end -- 2476
		persistHistoryState(shared) -- 2480
		__TS__Await(maybeCompressHistory(shared)) -- 2481
		persistHistoryState(shared) -- 2482
		return ____awaiter_resolve(nil, "main") -- 2482
	end) -- 2482
end -- 2457
local BuildAction = __TS__Class() -- 2487
BuildAction.name = "BuildAction" -- 2487
__TS__ClassExtends(BuildAction, Node) -- 2487
function BuildAction.prototype.prep(self, shared) -- 2488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2488
		local last = shared.history[#shared.history] -- 2489
		if not last then -- 2489
			error( -- 2490
				__TS__New(Error, "no history"), -- 2490
				0 -- 2490
			) -- 2490
		end -- 2490
		emitAgentStartEvent(shared, last) -- 2491
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2491
	end) -- 2491
end -- 2488
function BuildAction.prototype.exec(self, input) -- 2495
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2495
		local params = input.params -- 2496
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2497
		return ____awaiter_resolve(nil, result) -- 2497
	end) -- 2497
end -- 2495
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2504
		local last = shared.history[#shared.history] -- 2505
		if last ~= nil then -- 2505
			last.result = execRes -- 2507
			appendToolResultMessage(shared, last) -- 2508
			emitAgentFinishEvent(shared, last) -- 2509
		end -- 2509
		persistHistoryState(shared) -- 2511
		__TS__Await(maybeCompressHistory(shared)) -- 2512
		persistHistoryState(shared) -- 2513
		return ____awaiter_resolve(nil, "main") -- 2513
	end) -- 2513
end -- 2504
local EditFileAction = __TS__Class() -- 2518
EditFileAction.name = "EditFileAction" -- 2518
__TS__ClassExtends(EditFileAction, Node) -- 2518
function EditFileAction.prototype.prep(self, shared) -- 2519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2519
		local last = shared.history[#shared.history] -- 2520
		if not last then -- 2520
			error( -- 2521
				__TS__New(Error, "no history"), -- 2521
				0 -- 2521
			) -- 2521
		end -- 2521
		emitAgentStartEvent(shared, last) -- 2522
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2523
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 2526
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 2527
		if __TS__StringTrim(path) == "" then -- 2527
			error( -- 2528
				__TS__New(Error, "missing path"), -- 2528
				0 -- 2528
			) -- 2528
		end -- 2528
		return ____awaiter_resolve(nil, { -- 2528
			path = path, -- 2529
			oldStr = oldStr, -- 2529
			newStr = newStr, -- 2529
			taskId = shared.taskId, -- 2529
			workDir = shared.workingDir -- 2529
		}) -- 2529
	end) -- 2529
end -- 2519
function EditFileAction.prototype.exec(self, input) -- 2532
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2532
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 2533
		if not readRes.success then -- 2533
			if input.oldStr ~= "" then -- 2533
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 2533
			end -- 2533
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2538
			if not createRes.success then -- 2538
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 2538
			end -- 2538
			return ____awaiter_resolve(nil, { -- 2538
				success = true, -- 2546
				changed = true, -- 2547
				mode = "create", -- 2548
				checkpointId = createRes.checkpointId, -- 2549
				checkpointSeq = createRes.checkpointSeq, -- 2550
				files = {{path = input.path, op = "create"}} -- 2551
			}) -- 2551
		end -- 2551
		if input.oldStr == "" then -- 2551
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2555
			if not overwriteRes.success then -- 2555
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 2555
			end -- 2555
			return ____awaiter_resolve(nil, { -- 2555
				success = true, -- 2563
				changed = true, -- 2564
				mode = "overwrite", -- 2565
				checkpointId = overwriteRes.checkpointId, -- 2566
				checkpointSeq = overwriteRes.checkpointSeq, -- 2567
				files = {{path = input.path, op = "write"}} -- 2568
			}) -- 2568
		end -- 2568
		local normalizedContent = normalizeLineEndings(readRes.content) -- 2573
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 2574
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 2575
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 2578
		if occurrences == 0 then -- 2578
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2580
			if not indentTolerant.success then -- 2580
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 2580
			end -- 2580
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 2584
			if not applyRes.success then -- 2584
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2584
			end -- 2584
			return ____awaiter_resolve(nil, { -- 2584
				success = true, -- 2592
				changed = true, -- 2593
				mode = "replace_indent_tolerant", -- 2594
				checkpointId = applyRes.checkpointId, -- 2595
				checkpointSeq = applyRes.checkpointSeq, -- 2596
				files = {{path = input.path, op = "write"}} -- 2597
			}) -- 2597
		end -- 2597
		if occurrences > 1 then -- 2597
			return ____awaiter_resolve( -- 2597
				nil, -- 2597
				{ -- 2601
					success = false, -- 2601
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 2601
				} -- 2601
			) -- 2601
		end -- 2601
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 2605
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 2606
		if not applyRes.success then -- 2606
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 2606
		end -- 2606
		return ____awaiter_resolve(nil, { -- 2606
			success = true, -- 2614
			changed = true, -- 2615
			mode = "replace", -- 2616
			checkpointId = applyRes.checkpointId, -- 2617
			checkpointSeq = applyRes.checkpointSeq, -- 2618
			files = {{path = input.path, op = "write"}} -- 2619
		}) -- 2619
	end) -- 2619
end -- 2532
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2623
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2623
		local last = shared.history[#shared.history] -- 2624
		if last ~= nil then -- 2624
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 2626
			last.result = execRes -- 2627
			appendToolResultMessage(shared, last) -- 2628
			emitAgentFinishEvent(shared, last) -- 2629
			local result = last.result -- 2630
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2630
				emitAgentEvent(shared, { -- 2635
					type = "checkpoint_created", -- 2636
					sessionId = shared.sessionId, -- 2637
					taskId = shared.taskId, -- 2638
					step = last.step, -- 2639
					tool = last.tool, -- 2640
					checkpointId = result.checkpointId, -- 2641
					checkpointSeq = result.checkpointSeq, -- 2642
					files = result.files -- 2643
				}) -- 2643
			end -- 2643
		end -- 2643
		persistHistoryState(shared) -- 2647
		__TS__Await(maybeCompressHistory(shared)) -- 2648
		persistHistoryState(shared) -- 2649
		return ____awaiter_resolve(nil, "main") -- 2649
	end) -- 2649
end -- 2623
local EndNode = __TS__Class() -- 2654
EndNode.name = "EndNode" -- 2654
__TS__ClassExtends(EndNode, Node) -- 2654
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 2655
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2655
		return ____awaiter_resolve(nil, nil) -- 2655
	end) -- 2655
end -- 2655
local CodingAgentFlow = __TS__Class() -- 2660
CodingAgentFlow.name = "CodingAgentFlow" -- 2660
__TS__ClassExtends(CodingAgentFlow, Flow) -- 2660
function CodingAgentFlow.prototype.____constructor(self) -- 2661
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 2662
	local read = __TS__New(ReadFileAction, 1, 0) -- 2663
	local search = __TS__New(SearchFilesAction, 1, 0) -- 2664
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 2665
	local list = __TS__New(ListFilesAction, 1, 0) -- 2666
	local del = __TS__New(DeleteFileAction, 1, 0) -- 2667
	local build = __TS__New(BuildAction, 1, 0) -- 2668
	local edit = __TS__New(EditFileAction, 1, 0) -- 2669
	local done = __TS__New(EndNode, 1, 0) -- 2670
	main:on("read_file", read) -- 2672
	main:on("grep_files", search) -- 2673
	main:on("search_dora_api", searchDora) -- 2674
	main:on("glob_files", list) -- 2675
	main:on("delete_file", del) -- 2676
	main:on("build", build) -- 2677
	main:on("edit_file", edit) -- 2678
	main:on("done", done) -- 2679
	read:on("main", main) -- 2681
	search:on("main", main) -- 2682
	searchDora:on("main", main) -- 2683
	list:on("main", main) -- 2684
	del:on("main", main) -- 2685
	build:on("main", main) -- 2686
	edit:on("main", main) -- 2687
	Flow.prototype.____constructor(self, main) -- 2689
end -- 2661
local function runCodingAgentAsync(options) -- 2711
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2711
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 2711
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 2711
		end -- 2711
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 2715
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 2716
		if not llmConfigRes.success then -- 2716
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 2716
		end -- 2716
		local llmConfig = llmConfigRes.config -- 2722
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 2723
		if not taskRes.success then -- 2723
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 2723
		end -- 2723
		local compressor = __TS__New(MemoryCompressor, { -- 2730
			compressionThreshold = 0.8, -- 2731
			maxCompressionRounds = 3, -- 2732
			maxTokensPerCompression = 20000, -- 2733
			projectDir = options.workDir, -- 2734
			llmConfig = llmConfig, -- 2735
			promptPack = options.promptPack -- 2736
		}) -- 2736
		local persistedSession = compressor:getStorage():readSessionState() -- 2738
		local promptPack = compressor:getPromptPack() -- 2739
		local shared = { -- 2741
			sessionId = options.sessionId, -- 2742
			taskId = taskRes.taskId, -- 2743
			maxSteps = math.max( -- 2744
				1, -- 2744
				math.floor(options.maxSteps or 50) -- 2744
			), -- 2744
			llmMaxTry = math.max( -- 2745
				1, -- 2745
				math.floor(options.llmMaxTry or 3) -- 2745
			), -- 2745
			step = 0, -- 2746
			done = false, -- 2747
			stopToken = options.stopToken or ({stopped = false}), -- 2748
			response = "", -- 2749
			userQuery = normalizedPrompt, -- 2750
			workingDir = options.workDir, -- 2751
			useChineseResponse = options.useChineseResponse == true, -- 2752
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 2753
			llmOptions = __TS__ObjectAssign({temperature = 0.1, max_tokens = 8192}, options.llmOptions or ({})), -- 2756
			llmConfig = llmConfig, -- 2761
			onEvent = options.onEvent, -- 2762
			promptPack = promptPack, -- 2763
			history = {}, -- 2764
			messages = persistedSession.messages, -- 2765
			memory = {compressor = compressor}, -- 2767
			skills = {loader = createSkillsLoader({projectDir = options.workDir})} -- 2771
		} -- 2771
		local ____try = __TS__AsyncAwaiter(function() -- 2771
			emitAgentEvent(shared, { -- 2779
				type = "task_started", -- 2780
				sessionId = shared.sessionId, -- 2781
				taskId = shared.taskId, -- 2782
				prompt = shared.userQuery, -- 2783
				workDir = shared.workingDir, -- 2784
				maxSteps = shared.maxSteps -- 2785
			}) -- 2785
			if shared.stopToken.stopped then -- 2785
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2788
				return ____awaiter_resolve( -- 2788
					nil, -- 2788
					emitAgentTaskFinishEvent( -- 2789
						shared, -- 2789
						false, -- 2789
						getCancelledReason(shared) -- 2789
					) -- 2789
				) -- 2789
			end -- 2789
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 2791
			local promptCommand = getPromptCommand(shared.userQuery) -- 2792
			if promptCommand == "reset" then -- 2792
				return ____awaiter_resolve( -- 2792
					nil, -- 2792
					resetSessionHistory(shared) -- 2794
				) -- 2794
			end -- 2794
			if promptCommand == "compact" then -- 2794
				return ____awaiter_resolve( -- 2794
					nil, -- 2794
					__TS__Await(compactAllHistory(shared)) -- 2797
				) -- 2797
			end -- 2797
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 2799
			persistHistoryState(shared) -- 2803
			local flow = __TS__New(CodingAgentFlow) -- 2804
			__TS__Await(flow:run(shared)) -- 2805
			if shared.stopToken.stopped then -- 2805
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 2807
				return ____awaiter_resolve( -- 2807
					nil, -- 2807
					emitAgentTaskFinishEvent( -- 2808
						shared, -- 2808
						false, -- 2808
						getCancelledReason(shared) -- 2808
					) -- 2808
				) -- 2808
			end -- 2808
			if shared.error then -- 2808
				return ____awaiter_resolve( -- 2808
					nil, -- 2808
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 2811
				) -- 2811
			end -- 2811
			Tools.setTaskStatus(shared.taskId, "DONE") -- 2814
			return ____awaiter_resolve( -- 2814
				nil, -- 2814
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 2815
			) -- 2815
		end) -- 2815
		__TS__Await(____try.catch( -- 2778
			____try, -- 2778
			function(____, e) -- 2778
				return ____awaiter_resolve( -- 2778
					nil, -- 2778
					finalizeAgentFailure( -- 2818
						shared, -- 2818
						tostring(e) -- 2818
					) -- 2818
				) -- 2818
			end -- 2818
		)) -- 2818
	end) -- 2818
end -- 2711
function ____exports.runCodingAgent(options, callback) -- 2822
	local ____self_79 = runCodingAgentAsync(options) -- 2822
	____self_79["then"]( -- 2822
		____self_79, -- 2822
		function(____, result) return callback(result) end -- 2823
	) -- 2823
end -- 2822
return ____exports -- 2822