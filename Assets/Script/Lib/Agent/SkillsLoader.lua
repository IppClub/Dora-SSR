-- [ts]: SkillsLoader.ts
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
local ____exports = {} -- 1
local stripWrappingQuotes, parseSimpleYAML -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
function stripWrappingQuotes(value) -- 39
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 40
	result = string.gsub(result, "^'(.*)'$", "%1") -- 41
	return result -- 42
end -- 42
function parseSimpleYAML(text) -- 92
	if not text or __TS__StringTrim(text) == "" then -- 92
		return nil -- 94
	end -- 94
	local result = {} -- 97
	local lines = __TS__StringSplit(text, "\n") -- 98
	local currentKey = "" -- 99
	local currentArray = nil -- 100
	do -- 100
		local i = 0 -- 102
		while i < #lines do -- 102
			do -- 102
				local line = lines[i + 1] -- 103
				local trimmed = __TS__StringTrim(line) -- 104
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 104
					goto __continue16 -- 107
				end -- 107
				if __TS__StringStartsWith(trimmed, "- ") then -- 107
					if currentArray ~= nil and currentKey ~= "" then -- 107
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 112
						local cleaned = stripWrappingQuotes(value) -- 113
						currentArray[#currentArray + 1] = cleaned -- 114
					end -- 114
					goto __continue16 -- 116
				end -- 116
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 119
				if colonIndex > 0 then -- 119
					if currentArray ~= nil and currentKey ~= "" then -- 119
						result[currentKey] = currentArray -- 122
						currentArray = nil -- 123
					end -- 123
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 126
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 127
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 127
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 130
						local items = __TS__ArrayMap( -- 131
							__TS__StringSplit(arrayText, ","), -- 131
							function(____, item) -- 131
								local cleaned = stripWrappingQuotes(__TS__StringTrim(item)) -- 132
								return cleaned -- 133
							end -- 131
						) -- 131
						result[key] = items -- 135
						goto __continue16 -- 136
					end -- 136
					if value == "true" then -- 136
						result[key] = true -- 140
						goto __continue16 -- 141
					end -- 141
					if value == "false" then -- 141
						result[key] = false -- 144
						goto __continue16 -- 145
					end -- 145
					if value == "" then -- 145
						currentKey = key -- 149
						currentArray = {} -- 150
						if i + 1 < #lines then -- 150
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 152
							if not __TS__StringStartsWith(nextLine, "- ") then -- 152
								currentArray = nil -- 154
								result[key] = "" -- 155
							end -- 155
						else -- 155
							currentArray = nil -- 158
							result[key] = "" -- 159
						end -- 159
						goto __continue16 -- 161
					end -- 161
					local cleaned = stripWrappingQuotes(value) -- 164
					result[key] = cleaned -- 165
					currentKey = "" -- 166
					currentArray = nil -- 167
				end -- 167
			end -- 167
			::__continue16:: -- 167
			i = i + 1 -- 102
		end -- 102
	end -- 102
	if currentArray ~= nil and currentKey ~= "" then -- 102
		result[currentKey] = currentArray -- 172
	end -- 172
	return result -- 175
end -- 175
local SkillPriority = SkillPriority or ({}) -- 20
SkillPriority.BuiltIn = 0 -- 21
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 21
SkillPriority.User = 1 -- 22
SkillPriority[SkillPriority.User] = "User" -- 22
SkillPriority.Project = 2 -- 23
SkillPriority[SkillPriority.Project] = "Project" -- 23
local function isRecord(value) -- 31
	return type(value) == "table" and value ~= nil -- 32
end -- 31
local function isArray(value) -- 35
	return __TS__ArrayIsArray(value) -- 36
end -- 35
local function escapeXMLText(text) -- 45
	local result = string.gsub(text, "&", "&amp;") -- 46
	result = string.gsub(result, "<", "&lt;") -- 47
	result = string.gsub(result, ">", "&gt;") -- 48
	result = string.gsub(result, "\"", "&quot;") -- 49
	result = string.gsub(result, "'", "&apos;") -- 50
	return result -- 51
end -- 45
local function parseYAMLFrontmatter(content) -- 54
	if not content or __TS__StringTrim(content) == "" then -- 54
		return {metadata = nil, body = "", error = "empty content"} -- 60
	end -- 60
	local trimmed = __TS__StringTrim(content) -- 63
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 65
	end -- 65
	local lines = __TS__StringSplit(trimmed, "\n") -- 68
	local endLine = -1 -- 69
	do -- 69
		local i = 1 -- 70
		while i < #lines do -- 70
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 72
				break -- 73
			end -- 73
			i = i + 1 -- 70
		end -- 70
	end -- 70
	if endLine < 0 then -- 70
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 78
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 81
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 82
	local metadata = parseSimpleYAML(frontmatterText) -- 84
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 86
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 87
	return {metadata = metadata, body = body} -- 89
end -- 54
local function validateSkillMetadata(metadata) -- 178
	if not metadata then -- 178
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 182
	end -- 182
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 191
	if name == "" then -- 191
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 193
	end -- 193
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 202
	local always = metadata.always == true -- 206
	return {metadata = {name = name, description = description, always = always}} -- 208
end -- 178
____exports.SkillsLoader = __TS__Class() -- 217
local SkillsLoader = ____exports.SkillsLoader -- 217
SkillsLoader.name = "SkillsLoader" -- 217
function SkillsLoader.prototype.____constructor(self, config) -- 222
	self.skills = __TS__New(Map) -- 219
	self.loaded = false -- 220
	self.config = config -- 223
end -- 222
function SkillsLoader.prototype.load(self) -- 226
	self.skills:clear() -- 227
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 229
	local builtInParent = Content.assetPath -- 230
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 231
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 233
	local userParent = Content.writablePath -- 234
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 235
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 237
	local projectParent = self.config.projectDir -- 238
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 239
	self.loaded = true -- 241
	Log( -- 242
		"Info", -- 242
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 242
	) -- 242
end -- 226
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 245
	if not Content:exist(dir) or not Content:isdir(dir) then -- 245
		return -- 247
	end -- 247
	local subdirs = Content:getDirs(dir) -- 250
	if not subdirs or #subdirs == 0 then -- 250
		return -- 252
	end -- 252
	for ____, subdir in ipairs(subdirs) do -- 255
		do -- 255
			local skillPath = Path(dir, subdir, "SKILL.md") -- 256
			if not Content:exist(skillPath) then -- 256
				goto __continue39 -- 258
			end -- 258
			local skill = self:loadSkillFile(skillPath) -- 261
			if not skill then -- 261
				goto __continue39 -- 263
			end -- 263
			skill.location = Path:getRelative(skillPath, parent) -- 266
			local existing = self.skills:get(skill.name) -- 268
			if existing and existing.priority >= priority then -- 268
				goto __continue39 -- 270
			end -- 270
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 273
		end -- 273
		::__continue39:: -- 273
	end -- 273
end -- 245
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 277
	local content = Content:load(skillPath) -- 278
	if not content then -- 278
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 280
		return nil -- 281
	end -- 281
	local parsed = parseYAMLFrontmatter(content) -- 284
	local validated = validateSkillMetadata(parsed.metadata) -- 285
	if validated.error then -- 285
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 288
		return nil -- 289
	end -- 289
	local displayLocation = skillPath -- 292
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 292
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 294
	end -- 294
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 297
	return skill -- 303
end -- 277
function SkillsLoader.prototype.getAllSkills(self) -- 306
	if not self.loaded then -- 306
		self:load() -- 308
	end -- 308
	local result = {} -- 311
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 312
		result[#result + 1] = entry.skill -- 313
	end -- 313
	__TS__ArraySort(result) -- 316
	return result -- 318
end -- 306
function SkillsLoader.prototype.getSkill(self, name) -- 321
	if not self.loaded then -- 321
		self:load() -- 323
	end -- 323
	local ____opt_0 = self.skills:get(name) -- 323
	return ____opt_0 and ____opt_0.skill -- 326
end -- 321
function SkillsLoader.prototype.getAlwaysSkills(self) -- 329
	local all = self:getAllSkills() -- 330
	return __TS__ArrayFilter( -- 331
		all, -- 331
		function(____, skill) return skill.always == true end -- 331
	) -- 331
end -- 329
function SkillsLoader.prototype.getSummarySkills(self) -- 334
	local all = self:getAllSkills() -- 335
	return __TS__ArrayFilter( -- 336
		all, -- 336
		function(____, skill) return skill.always ~= true end -- 336
	) -- 336
end -- 334
function SkillsLoader.prototype.buildLevel1Summary(self) -- 339
	local skills = self:getSummarySkills() -- 340
	if #skills == 0 then -- 340
		return "" -- 343
	end -- 343
	local parts = {} -- 346
	for ____, skill in ipairs(skills) do -- 348
		local skillXML = "<skill>\n" -- 349
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 350
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 351
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 352
		skillXML = skillXML .. "</skill>" -- 353
		parts[#parts + 1] = skillXML -- 354
	end -- 354
	return table.concat(parts, "\n\n") -- 357
end -- 339
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 360
	local skills = self:getAlwaysSkills() -- 361
	if #skills == 0 then -- 361
		return "" -- 364
	end -- 364
	local parts = {} -- 367
	for ____, skill in ipairs(skills) do -- 369
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 370
		if skill.description ~= nil then -- 370
			parts[#parts + 1] = skill.description .. "\n" -- 372
		end -- 372
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 372
			parts[#parts + 1] = "\n" .. skill.body -- 375
		end -- 375
		parts[#parts + 1] = "" -- 377
	end -- 377
	return table.concat(parts, "\n") -- 380
end -- 360
function SkillsLoader.prototype.loadSkillContent(self, name) -- 383
	local skill = self:getSkill(name) -- 384
	if not skill then -- 384
		return nil -- 386
	end -- 386
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 386
		return skill.body -- 390
	end -- 390
	local content = Content:load(skill.location) -- 393
	if not content then -- 393
		return nil -- 395
	end -- 395
	local parsed = parseYAMLFrontmatter(content) -- 398
	return parsed.body or nil -- 399
end -- 383
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 402
	if not self.loaded then -- 402
		self:load() -- 404
	end -- 404
	local sections = {} -- 407
	local activeContent = self:buildActiveSkillsContent() -- 409
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 410
	local summary = self:buildLevel1Summary() -- 412
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 413
	return table.concat(sections, "\n\n---\n\n")
end -- 402
function SkillsLoader.prototype.escapeXML(self, text) -- 418
	return escapeXMLText(text) -- 419
end -- 418
function SkillsLoader.prototype.reload(self) -- 422
	self.loaded = false -- 423
	self:load() -- 424
end -- 422
function SkillsLoader.prototype.getSkillCount(self) -- 427
	if not self.loaded then -- 427
		self:load() -- 429
	end -- 429
	return self.skills.size -- 431
end -- 427
function ____exports.createSkillsLoader(config) -- 435
	return __TS__New(____exports.SkillsLoader, config) -- 436
end -- 435
return ____exports -- 435