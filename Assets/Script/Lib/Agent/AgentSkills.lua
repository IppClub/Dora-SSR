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
function normalizeStringList(value) -- 211
	if type(value) == "string" then -- 211
		local trimmed = __TS__StringTrim(value) -- 213
		local ____temp_0 -- 214
		if trimmed == "" then -- 214
			____temp_0 = nil -- 214
		else -- 214
			____temp_0 = {trimmed} -- 214
		end -- 214
		return ____temp_0 -- 214
	end -- 214
	if not __TS__ArrayIsArray(value) then -- 214
		return nil -- 217
	end -- 217
	local result = {} -- 219
	for ____, item in ipairs(value) do -- 220
		do -- 220
			if type(item) ~= "string" then -- 220
				goto __continue35 -- 222
			end -- 222
			local trimmed = __TS__StringTrim(item) -- 224
			if trimmed ~= "" and __TS__ArrayIndexOf(result, trimmed) < 0 then -- 224
				result[#result + 1] = trimmed -- 226
			end -- 226
		end -- 226
		::__continue35:: -- 226
	end -- 226
	return #result > 0 and result or nil -- 229
end -- 229
local SkillPriority = SkillPriority or ({}) -- 23
SkillPriority.BuiltIn = 0 -- 24
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 24
SkillPriority.User = 1 -- 25
SkillPriority[SkillPriority.User] = "User" -- 25
SkillPriority.Project = 2 -- 26
SkillPriority[SkillPriority.Project] = "Project" -- 26
local function stripWrappingQuotes(value) -- 34
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 35
	result = string.gsub(result, "^'(.*)'$", "%1") -- 36
	return result -- 37
end -- 34
local function escapeXMLText(text) -- 40
	local result = string.gsub(text, "&", "&amp;") -- 41
	result = string.gsub(result, "<", "&lt;") -- 42
	result = string.gsub(result, ">", "&gt;") -- 43
	result = string.gsub(result, "\"", "&quot;") -- 44
	result = string.gsub(result, "'", "&apos;") -- 45
	return result -- 46
end -- 40
local function parseSimpleYAML(text) -- 49
	if not text or __TS__StringTrim(text) == "" then -- 49
		return nil -- 51
	end -- 51
	local result = {} -- 54
	local lines = __TS__StringSplit(text, "\n") -- 55
	local currentKey = "" -- 56
	local currentArray = nil -- 57
	do -- 57
		local i = 0 -- 59
		while i < #lines do -- 59
			do -- 59
				local line = lines[i + 1] -- 60
				local trimmed = __TS__StringTrim(line) -- 61
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 61
					goto __continue7 -- 64
				end -- 64
				if __TS__StringStartsWith(trimmed, "- ") then -- 64
					if currentArray ~= nil and currentKey ~= "" then -- 64
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 69
						local cleaned = stripWrappingQuotes(value) -- 70
						currentArray[#currentArray + 1] = cleaned -- 71
					end -- 71
					goto __continue7 -- 73
				end -- 73
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 76
				if colonIndex > 0 then -- 76
					if currentArray ~= nil and currentKey ~= "" then -- 76
						result[currentKey] = currentArray -- 79
						currentArray = nil -- 80
					end -- 80
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 83
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 84
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 84
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 87
						local items = value == "[]" and ({}) or __TS__ArrayMap( -- 88
							__TS__StringSplit(arrayText, ","), -- 90
							function(____, item) return stripWrappingQuotes(__TS__StringTrim(item)) end -- 90
						) -- 90
						result[key] = items -- 91
						goto __continue7 -- 92
					end -- 92
					if value == "true" then -- 92
						result[key] = true -- 96
						goto __continue7 -- 97
					end -- 97
					if value == "false" then -- 97
						result[key] = false -- 100
						goto __continue7 -- 101
					end -- 101
					if value == "" then -- 101
						currentKey = key -- 105
						currentArray = {} -- 106
						if i + 1 < #lines then -- 106
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 108
							if not __TS__StringStartsWith(nextLine, "- ") then -- 108
								currentArray = nil -- 110
								result[key] = "" -- 111
							end -- 111
						else -- 111
							currentArray = nil -- 114
							result[key] = "" -- 115
						end -- 115
						goto __continue7 -- 117
					end -- 117
					local cleaned = stripWrappingQuotes(value) -- 120
					result[key] = cleaned -- 121
					currentKey = "" -- 122
					currentArray = nil -- 123
				end -- 123
			end -- 123
			::__continue7:: -- 123
			i = i + 1 -- 59
		end -- 59
	end -- 59
	if currentArray ~= nil and currentKey ~= "" then -- 59
		result[currentKey] = currentArray -- 128
	end -- 128
	return result -- 131
end -- 49
local function parseYAMLFrontmatter(content) -- 134
	if not content or __TS__StringTrim(content) == "" then -- 134
		return {metadata = nil, body = "", error = "empty content"} -- 140
	end -- 140
	local trimmed = __TS__StringTrim(content) -- 143
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 145
	end -- 145
	local lines = __TS__StringSplit(trimmed, "\n") -- 148
	local endLine = -1 -- 149
	do -- 149
		local i = 1 -- 150
		while i < #lines do -- 150
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 152
				break -- 153
			end -- 153
			i = i + 1 -- 150
		end -- 150
	end -- 150
	if endLine < 0 then -- 150
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 158
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 161
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 162
	local metadata = parseSimpleYAML(frontmatterText) -- 163
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 164
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 165
	return {metadata = metadata, body = body} -- 167
end -- 134
local function validateSkillMetadata(metadata) -- 170
	if not metadata then -- 170
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 174
	end -- 174
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 183
	if name == "" then -- 183
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 185
	end -- 185
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 194
	local always = metadata.always == true -- 198
	local requiredTools = normalizeStringList(metadata.requiredTools) -- 199
	return {metadata = {name = name, description = description, always = always, requiredTools = requiredTools}} -- 201
end -- 170
____exports.SkillsLoader = __TS__Class() -- 232
local SkillsLoader = ____exports.SkillsLoader -- 232
SkillsLoader.name = "SkillsLoader" -- 232
function SkillsLoader.prototype.____constructor(self, config) -- 237
	self.skills = __TS__New(Map) -- 234
	self.loaded = false -- 235
	self.config = config -- 238
end -- 237
function SkillsLoader.prototype.load(self) -- 241
	self.skills:clear() -- 242
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 244
	local builtInParent = Content.assetPath -- 245
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 246
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 248
	local userParent = Content.writablePath -- 249
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 250
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 252
	local projectParent = self.config.projectDir -- 253
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 254
	self.loaded = true -- 256
	Log( -- 257
		"Info", -- 257
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 257
	) -- 257
end -- 241
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 260
	if not Content:exist(dir) or not Content:isdir(dir) then -- 260
		return -- 262
	end -- 262
	local subdirs = Content:getDirs(dir) -- 265
	if not subdirs or #subdirs == 0 then -- 265
		return -- 267
	end -- 267
	for ____, subdir in ipairs(subdirs) do -- 270
		do -- 270
			local skillPath = Path(dir, subdir, "SKILL.md") -- 271
			if not Content:exist(skillPath) then -- 271
				goto __continue44 -- 273
			end -- 273
			local skill = self:loadSkillFile(skillPath) -- 276
			if not skill then -- 276
				goto __continue44 -- 278
			end -- 278
			skill.location = Path:getRelative(skillPath, parent) -- 281
			local existing = self.skills:get(skill.name) -- 283
			if existing and existing.priority >= priority then -- 283
				goto __continue44 -- 285
			end -- 285
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 288
		end -- 288
		::__continue44:: -- 288
	end -- 288
end -- 260
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 292
	local content = Content:load(skillPath) -- 293
	if not content then -- 293
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 295
		return nil -- 296
	end -- 296
	local parsed = parseYAMLFrontmatter(content) -- 299
	local validated = validateSkillMetadata(parsed.metadata) -- 300
	if validated.error then -- 300
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 303
		return nil -- 304
	end -- 304
	local displayLocation = skillPath -- 307
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 307
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 309
	end -- 309
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 312
	return skill -- 318
end -- 292
function SkillsLoader.prototype.getAllSkills(self) -- 321
	if not self.loaded then -- 321
		self:load() -- 323
	end -- 323
	local result = {} -- 326
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 327
		do -- 327
			if not self:isSkillEnabled(entry.skill) then -- 327
				goto __continue55 -- 329
			end -- 329
			result[#result + 1] = entry.skill -- 331
		end -- 331
		::__continue55:: -- 331
	end -- 331
	__TS__ArraySort( -- 334
		result, -- 334
		function(____, a, b) -- 334
			if a.name < b.name then -- 334
				return -1 -- 336
			end -- 336
			if a.name > b.name then -- 336
				return 1 -- 339
			end -- 339
			if a.location < b.location then -- 339
				return -1 -- 342
			end -- 342
			if a.location > b.location then -- 342
				return 1 -- 345
			end -- 345
			return 0 -- 347
		end -- 334
	) -- 334
	return result -- 350
end -- 321
function SkillsLoader.prototype.getSkill(self, name) -- 353
	if not self.loaded then -- 353
		self:load() -- 355
	end -- 355
	local ____opt_1 = self.skills:get(name) -- 355
	local skill = ____opt_1 and ____opt_1.skill -- 358
	if not skill or not self:isSkillEnabled(skill) then -- 358
		return nil -- 360
	end -- 360
	return skill -- 362
end -- 353
function SkillsLoader.prototype.getAlwaysSkills(self) -- 365
	local all = self:getAllSkills() -- 366
	return __TS__ArrayFilter( -- 367
		all, -- 367
		function(____, skill) return skill.always == true end -- 367
	) -- 367
end -- 365
function SkillsLoader.prototype.getSummarySkills(self) -- 370
	local all = self:getAllSkills() -- 371
	return __TS__ArrayFilter( -- 372
		all, -- 372
		function(____, skill) return skill.always ~= true end -- 372
	) -- 372
end -- 370
function SkillsLoader.prototype.buildLevel1Summary(self) -- 375
	local skills = self:getSummarySkills() -- 376
	if #skills == 0 then -- 376
		return "" -- 379
	end -- 379
	local parts = {} -- 382
	for ____, skill in ipairs(skills) do -- 384
		local skillXML = "<skill>\n" -- 385
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 386
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 387
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 388
		skillXML = skillXML .. "</skill>" -- 389
		parts[#parts + 1] = skillXML -- 390
	end -- 390
	return table.concat(parts, "\n\n") -- 393
end -- 375
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 396
	local skills = self:getAlwaysSkills() -- 397
	if #skills == 0 then -- 397
		return "" -- 400
	end -- 400
	local parts = {} -- 403
	for ____, skill in ipairs(skills) do -- 405
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 406
		if skill.description ~= nil then -- 406
			parts[#parts + 1] = skill.description .. "\n" -- 408
		end -- 408
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 408
			parts[#parts + 1] = "\n" .. skill.body -- 411
		end -- 411
		parts[#parts + 1] = "" -- 413
	end -- 413
	return table.concat(parts, "\n") -- 416
end -- 396
function SkillsLoader.prototype.loadSkillContent(self, name) -- 419
	local skill = self:getSkill(name) -- 420
	if not skill then -- 420
		return nil -- 422
	end -- 422
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 422
		return skill.body -- 426
	end -- 426
	local content = Content:load(skill.location) -- 429
	if not content then -- 429
		return nil -- 431
	end -- 431
	local parsed = parseYAMLFrontmatter(content) -- 434
	if parsed.body == "" then -- 434
		return nil -- 436
	end -- 436
	return parsed.body -- 438
end -- 419
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 441
	if not self.loaded then -- 441
		self:load() -- 443
	end -- 443
	local sections = {} -- 446
	local activeContent = self:buildActiveSkillsContent() -- 448
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 449
	local summary = self:buildLevel1Summary() -- 451
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 452
	return table.concat(sections, "\n\n---\n\n")
end -- 441
function SkillsLoader.prototype.escapeXML(self, text) -- 457
	return escapeXMLText(text) -- 458
end -- 457
function SkillsLoader.prototype.isSkillEnabled(self, skill) -- 461
	local requiredTools = skill.requiredTools or ({}) -- 462
	if #requiredTools == 0 then -- 462
		return true -- 464
	end -- 464
	local disabledTools = self.config.disabledAgentTools or ({}) -- 466
	local allowedTools = self.config.allowedAgentTools -- 467
	for ____, tool in ipairs(requiredTools) do -- 468
		if __TS__ArrayIndexOf(disabledTools, tool) >= 0 then -- 468
			return false -- 470
		end -- 470
		if allowedTools ~= nil and __TS__ArrayIndexOf(allowedTools, tool) < 0 then -- 470
			return false -- 472
		end -- 472
	end -- 472
	return true -- 474
end -- 461
function SkillsLoader.prototype.reload(self) -- 477
	self.loaded = false -- 478
	self:load() -- 479
end -- 477
function SkillsLoader.prototype.getSkillCount(self) -- 482
	if not self.loaded then -- 482
		self:load() -- 484
	end -- 484
	return self.skills.size -- 486
end -- 482
function ____exports.createSkillsLoader(config) -- 490
	return __TS__New(____exports.SkillsLoader, config) -- 491
end -- 490
return ____exports -- 490