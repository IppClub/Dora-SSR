-- [ts]: AgentSkills.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local normalizeStringList -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
function normalizeStringList(value) -- 212
	if type(value) == "string" then -- 212
		local trimmed = __TS__StringTrim(value) -- 214
		local ____temp_0 -- 215
		if trimmed == "" then -- 215
			____temp_0 = nil -- 215
		else -- 215
			____temp_0 = {trimmed} -- 215
		end -- 215
		return ____temp_0 -- 215
	end -- 215
	if not __TS__ArrayIsArray(value) then -- 215
		return nil -- 218
	end -- 218
	local result = {} -- 220
	for ____, item in ipairs(value) do -- 221
		do -- 221
			if type(item) ~= "string" then -- 221
				goto __continue35 -- 223
			end -- 223
			local trimmed = __TS__StringTrim(item) -- 225
			if trimmed ~= "" and __TS__ArrayIndexOf(result, trimmed) < 0 then -- 225
				result[#result + 1] = trimmed -- 227
			end -- 227
		end -- 227
		::__continue35:: -- 227
	end -- 227
	return #result > 0 and result or nil -- 230
end -- 230
local SkillPriority = SkillPriority or ({}) -- 24
SkillPriority.BuiltIn = 0 -- 25
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 25
SkillPriority.User = 1 -- 26
SkillPriority[SkillPriority.User] = "User" -- 26
SkillPriority.Project = 2 -- 27
SkillPriority[SkillPriority.Project] = "Project" -- 27
local function stripWrappingQuotes(value) -- 35
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 36
	result = string.gsub(result, "^'(.*)'$", "%1") -- 37
	return result -- 38
end -- 35
local function escapeXMLText(text) -- 41
	local result = string.gsub(text, "&", "&amp;") -- 42
	result = string.gsub(result, "<", "&lt;") -- 43
	result = string.gsub(result, ">", "&gt;") -- 44
	result = string.gsub(result, "\"", "&quot;") -- 45
	result = string.gsub(result, "'", "&apos;") -- 46
	return result -- 47
end -- 41
local function parseSimpleYAML(text) -- 50
	if not text or __TS__StringTrim(text) == "" then -- 50
		return nil -- 52
	end -- 52
	local result = {} -- 55
	local lines = __TS__StringSplit(text, "\n") -- 56
	local currentKey = "" -- 57
	local currentArray = nil -- 58
	do -- 58
		local i = 0 -- 60
		while i < #lines do -- 60
			do -- 60
				local line = lines[i + 1] -- 61
				local trimmed = __TS__StringTrim(line) -- 62
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 62
					goto __continue7 -- 65
				end -- 65
				if __TS__StringStartsWith(trimmed, "- ") then -- 65
					if currentArray ~= nil and currentKey ~= "" then -- 65
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 70
						local cleaned = stripWrappingQuotes(value) -- 71
						currentArray[#currentArray + 1] = cleaned -- 72
					end -- 72
					goto __continue7 -- 74
				end -- 74
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 77
				if colonIndex > 0 then -- 77
					if currentArray ~= nil and currentKey ~= "" then -- 77
						result[currentKey] = currentArray -- 80
						currentArray = nil -- 81
					end -- 81
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 84
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 85
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 85
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 88
						local items = value == "[]" and ({}) or __TS__ArrayMap( -- 89
							__TS__StringSplit(arrayText, ","), -- 91
							function(____, item) return stripWrappingQuotes(__TS__StringTrim(item)) end -- 91
						) -- 91
						result[key] = items -- 92
						goto __continue7 -- 93
					end -- 93
					if value == "true" then -- 93
						result[key] = true -- 97
						goto __continue7 -- 98
					end -- 98
					if value == "false" then -- 98
						result[key] = false -- 101
						goto __continue7 -- 102
					end -- 102
					if value == "" then -- 102
						currentKey = key -- 106
						currentArray = {} -- 107
						if i + 1 < #lines then -- 107
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 109
							if not __TS__StringStartsWith(nextLine, "- ") then -- 109
								currentArray = nil -- 111
								result[key] = "" -- 112
							end -- 112
						else -- 112
							currentArray = nil -- 115
							result[key] = "" -- 116
						end -- 116
						goto __continue7 -- 118
					end -- 118
					local cleaned = stripWrappingQuotes(value) -- 121
					result[key] = cleaned -- 122
					currentKey = "" -- 123
					currentArray = nil -- 124
				end -- 124
			end -- 124
			::__continue7:: -- 124
			i = i + 1 -- 60
		end -- 60
	end -- 60
	if currentArray ~= nil and currentKey ~= "" then -- 60
		result[currentKey] = currentArray -- 129
	end -- 129
	return result -- 132
end -- 50
local function parseYAMLFrontmatter(content) -- 135
	if not content or __TS__StringTrim(content) == "" then -- 135
		return {metadata = nil, body = "", error = "empty content"} -- 141
	end -- 141
	local trimmed = __TS__StringTrim(content) -- 144
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 146
	end -- 146
	local lines = __TS__StringSplit(trimmed, "\n") -- 149
	local endLine = -1 -- 150
	do -- 150
		local i = 1 -- 151
		while i < #lines do -- 151
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 153
				break -- 154
			end -- 154
			i = i + 1 -- 151
		end -- 151
	end -- 151
	if endLine < 0 then -- 151
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 159
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 162
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 163
	local metadata = parseSimpleYAML(frontmatterText) -- 164
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 165
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 166
	return {metadata = metadata, body = body} -- 168
end -- 135
local function validateSkillMetadata(metadata) -- 171
	if not metadata then -- 171
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 175
	end -- 175
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 184
	if name == "" then -- 184
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 186
	end -- 186
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 195
	local always = metadata.always == true -- 199
	local requiredTools = normalizeStringList(metadata.requiredTools) -- 200
	return {metadata = {name = name, description = description, always = always, requiredTools = requiredTools}} -- 202
end -- 171
____exports.SkillsLoader = __TS__Class() -- 233
local SkillsLoader = ____exports.SkillsLoader -- 233
SkillsLoader.name = "SkillsLoader" -- 233
function SkillsLoader.prototype.____constructor(self, config) -- 238
	self.skills = __TS__New(Map) -- 235
	self.loaded = false -- 236
	self.config = config -- 239
end -- 238
function SkillsLoader.prototype.load(self) -- 242
	self.skills:clear() -- 243
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 245
	self:loadSkillsFromDir(builtInDir, SkillPriority.BuiltIn) -- 246
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 248
	self:loadSkillsFromDir(userDir, SkillPriority.User) -- 249
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 251
	self:loadSkillsFromDir(projectDir, SkillPriority.Project) -- 252
	self.loaded = true -- 254
	Log( -- 255
		"Info", -- 255
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 255
	) -- 255
end -- 242
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, priority) -- 258
	if not Content:exist(dir) or not Content:isdir(dir) then -- 258
		return -- 260
	end -- 260
	local subdirs = Content:getDirs(dir) -- 263
	if not subdirs or #subdirs == 0 then -- 263
		return -- 265
	end -- 265
	for ____, subdir in ipairs(subdirs) do -- 268
		do -- 268
			local skillPath = Path(dir, subdir, "SKILL.md") -- 269
			if not Content:exist(skillPath) then -- 269
				goto __continue44 -- 271
			end -- 271
			local skill = self:loadSkillFile(skillPath) -- 274
			if not skill then -- 274
				goto __continue44 -- 276
			end -- 276
			local relative = table.concat( -- 279
				__TS__StringSplit( -- 279
					Path:getRelative(skillPath, dir), -- 279
					"\\" -- 279
				), -- 279
				"/" -- 279
			) -- 279
			skill.location = priority == SkillPriority.BuiltIn and "@agent-skill/builtin/" .. relative or (priority == SkillPriority.User and "@agent-skill/user/" .. relative or ".agent/skills/" .. relative) -- 280
			local existing = self.skills:get(skill.name) -- 286
			if existing and existing.priority >= priority then -- 286
				goto __continue44 -- 288
			end -- 288
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 291
		end -- 291
		::__continue44:: -- 291
	end -- 291
end -- 258
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 295
	local content = Content:load(skillPath) -- 296
	if not content then -- 296
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 298
		return nil -- 299
	end -- 299
	local parsed = parseYAMLFrontmatter(content) -- 302
	local validated = validateSkillMetadata(parsed.metadata) -- 303
	if validated.error then -- 303
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 306
		return nil -- 307
	end -- 307
	local displayLocation = skillPath -- 310
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 310
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 312
	end -- 312
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, sourcePath = skillPath, body = parsed.body}) -- 315
	return skill -- 322
end -- 295
function SkillsLoader.prototype.getAllSkills(self) -- 325
	if not self.loaded then -- 325
		self:load() -- 327
	end -- 327
	local result = {} -- 330
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 331
		do -- 331
			if not self:isSkillEnabled(entry.skill) then -- 331
				goto __continue55 -- 333
			end -- 333
			result[#result + 1] = entry.skill -- 335
		end -- 335
		::__continue55:: -- 335
	end -- 335
	__TS__ArraySort( -- 338
		result, -- 338
		function(____, a, b) -- 338
			if a.name < b.name then -- 338
				return -1 -- 340
			end -- 340
			if a.name > b.name then -- 340
				return 1 -- 343
			end -- 343
			if a.location < b.location then -- 343
				return -1 -- 346
			end -- 346
			if a.location > b.location then -- 346
				return 1 -- 349
			end -- 349
			return 0 -- 351
		end -- 338
	) -- 338
	return result -- 354
end -- 325
function SkillsLoader.prototype.getSkill(self, name) -- 357
	if not self.loaded then -- 357
		self:load() -- 359
	end -- 359
	local ____opt_1 = self.skills:get(name) -- 359
	local skill = ____opt_1 and ____opt_1.skill -- 362
	if not skill or not self:isSkillEnabled(skill) then -- 362
		return nil -- 364
	end -- 364
	return skill -- 366
end -- 357
function SkillsLoader.prototype.getAlwaysSkills(self) -- 369
	local all = self:getAllSkills() -- 370
	return __TS__ArrayFilter( -- 371
		all, -- 371
		function(____, skill) return skill.always == true end -- 371
	) -- 371
end -- 369
function SkillsLoader.prototype.getSummarySkills(self) -- 374
	local all = self:getAllSkills() -- 375
	return __TS__ArrayFilter( -- 376
		all, -- 376
		function(____, skill) return skill.always ~= true end -- 376
	) -- 376
end -- 374
function SkillsLoader.prototype.buildLevel1Summary(self) -- 379
	local skills = self:getSummarySkills() -- 380
	if #skills == 0 then -- 380
		return "" -- 383
	end -- 383
	local parts = {} -- 386
	for ____, skill in ipairs(skills) do -- 388
		local skillXML = "<skill>\n" -- 389
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 390
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 391
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 392
		skillXML = skillXML .. "</skill>" -- 393
		parts[#parts + 1] = skillXML -- 394
	end -- 394
	return table.concat(parts, "\n\n") -- 397
end -- 379
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 400
	local skills = self:getAlwaysSkills() -- 401
	if #skills == 0 then -- 401
		return "" -- 404
	end -- 404
	local parts = {} -- 407
	for ____, skill in ipairs(skills) do -- 409
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 410
		if skill.description ~= nil then -- 410
			parts[#parts + 1] = skill.description .. "\n" -- 412
		end -- 412
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 412
			parts[#parts + 1] = "\n" .. skill.body -- 415
		end -- 415
		parts[#parts + 1] = "" -- 417
	end -- 417
	return table.concat(parts, "\n") -- 420
end -- 400
function SkillsLoader.prototype.loadSkillContent(self, name) -- 423
	local skill = self:getSkill(name) -- 424
	if not skill then -- 424
		return nil -- 426
	end -- 426
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 426
		return skill.body -- 430
	end -- 430
	local content = Content:load(skill.sourcePath) -- 433
	if not content then -- 433
		return nil -- 435
	end -- 435
	local parsed = parseYAMLFrontmatter(content) -- 438
	if parsed.body == "" then -- 438
		return nil -- 440
	end -- 440
	return parsed.body -- 442
end -- 423
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 445
	if not self.loaded then -- 445
		self:load() -- 447
	end -- 447
	local sections = {} -- 450
	local activeContent = self:buildActiveSkillsContent() -- 452
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 453
	local summary = self:buildLevel1Summary() -- 455
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 456
	return table.concat(sections, "\n\n---\n\n")
end -- 445
function SkillsLoader.prototype.escapeXML(self, text) -- 461
	return escapeXMLText(text) -- 462
end -- 461
function SkillsLoader.prototype.isSkillEnabled(self, skill) -- 465
	local requiredTools = skill.requiredTools or ({}) -- 466
	if #requiredTools == 0 then -- 466
		return true -- 468
	end -- 468
	local disabledTools = self.config.disabledAgentTools or ({}) -- 470
	local allowedTools = self.config.allowedAgentTools -- 471
	for ____, tool in ipairs(requiredTools) do -- 472
		if __TS__ArrayIndexOf(disabledTools, tool) >= 0 then -- 472
			return false -- 474
		end -- 474
		if allowedTools ~= nil and __TS__ArrayIndexOf(allowedTools, tool) < 0 then -- 474
			return false -- 476
		end -- 476
	end -- 476
	return true -- 478
end -- 465
function SkillsLoader.prototype.reload(self) -- 481
	self.loaded = false -- 482
	self:load() -- 483
end -- 481
function SkillsLoader.prototype.getSkillCount(self) -- 486
	if not self.loaded then -- 486
		self:load() -- 488
	end -- 488
	return self.skills.size -- 490
end -- 486
function ____exports.createSkillsLoader(config) -- 494
	return __TS__New(____exports.SkillsLoader, config) -- 495
end -- 494
return ____exports -- 494