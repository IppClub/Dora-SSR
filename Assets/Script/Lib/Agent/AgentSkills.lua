-- [ts]: AgentSkills.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local SkillPriority = SkillPriority or ({}) -- 20
SkillPriority.BuiltIn = 0 -- 21
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 21
SkillPriority.User = 1 -- 22
SkillPriority[SkillPriority.User] = "User" -- 22
SkillPriority.Project = 2 -- 23
SkillPriority[SkillPriority.Project] = "Project" -- 23
local function stripWrappingQuotes(value) -- 31
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 32
	result = string.gsub(result, "^'(.*)'$", "%1") -- 33
	return result -- 34
end -- 31
local function escapeXMLText(text) -- 37
	local result = string.gsub(text, "&", "&amp;") -- 38
	result = string.gsub(result, "<", "&lt;") -- 39
	result = string.gsub(result, ">", "&gt;") -- 40
	result = string.gsub(result, "\"", "&quot;") -- 41
	result = string.gsub(result, "'", "&apos;") -- 42
	return result -- 43
end -- 37
local function parseSimpleYAML(text) -- 46
	if not text or __TS__StringTrim(text) == "" then -- 46
		return nil -- 48
	end -- 48
	local result = {} -- 51
	local lines = __TS__StringSplit(text, "\n") -- 52
	local currentKey = "" -- 53
	local currentArray = nil -- 54
	do -- 54
		local i = 0 -- 56
		while i < #lines do -- 56
			do -- 56
				local line = lines[i + 1] -- 57
				local trimmed = __TS__StringTrim(line) -- 58
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 58
					goto __continue7 -- 61
				end -- 61
				if __TS__StringStartsWith(trimmed, "- ") then -- 61
					if currentArray ~= nil and currentKey ~= "" then -- 61
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 66
						local cleaned = stripWrappingQuotes(value) -- 67
						currentArray[#currentArray + 1] = cleaned -- 68
					end -- 68
					goto __continue7 -- 70
				end -- 70
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 73
				if colonIndex > 0 then -- 73
					if currentArray ~= nil and currentKey ~= "" then -- 73
						result[currentKey] = currentArray -- 76
						currentArray = nil -- 77
					end -- 77
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 80
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 81
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 81
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 84
						local items = value == "[]" and ({}) or __TS__ArrayMap( -- 85
							__TS__StringSplit(arrayText, ","), -- 87
							function(____, item) return stripWrappingQuotes(__TS__StringTrim(item)) end -- 87
						) -- 87
						result[key] = items -- 88
						goto __continue7 -- 89
					end -- 89
					if value == "true" then -- 89
						result[key] = true -- 93
						goto __continue7 -- 94
					end -- 94
					if value == "false" then -- 94
						result[key] = false -- 97
						goto __continue7 -- 98
					end -- 98
					if value == "" then -- 98
						currentKey = key -- 102
						currentArray = {} -- 103
						if i + 1 < #lines then -- 103
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 105
							if not __TS__StringStartsWith(nextLine, "- ") then -- 105
								currentArray = nil -- 107
								result[key] = "" -- 108
							end -- 108
						else -- 108
							currentArray = nil -- 111
							result[key] = "" -- 112
						end -- 112
						goto __continue7 -- 114
					end -- 114
					local cleaned = stripWrappingQuotes(value) -- 117
					result[key] = cleaned -- 118
					currentKey = "" -- 119
					currentArray = nil -- 120
				end -- 120
			end -- 120
			::__continue7:: -- 120
			i = i + 1 -- 56
		end -- 56
	end -- 56
	if currentArray ~= nil and currentKey ~= "" then -- 56
		result[currentKey] = currentArray -- 125
	end -- 125
	return result -- 128
end -- 46
local function parseYAMLFrontmatter(content) -- 131
	if not content or __TS__StringTrim(content) == "" then -- 131
		return {metadata = nil, body = "", error = "empty content"} -- 137
	end -- 137
	local trimmed = __TS__StringTrim(content) -- 140
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 142
	end -- 142
	local lines = __TS__StringSplit(trimmed, "\n") -- 145
	local endLine = -1 -- 146
	do -- 146
		local i = 1 -- 147
		while i < #lines do -- 147
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 149
				break -- 150
			end -- 150
			i = i + 1 -- 147
		end -- 147
	end -- 147
	if endLine < 0 then -- 147
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 155
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 158
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 159
	local metadata = parseSimpleYAML(frontmatterText) -- 160
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 161
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 162
	return {metadata = metadata, body = body} -- 164
end -- 131
local function validateSkillMetadata(metadata) -- 167
	if not metadata then -- 167
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 171
	end -- 171
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 180
	if name == "" then -- 180
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 182
	end -- 182
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 191
	local always = metadata.always == true -- 195
	return {metadata = {name = name, description = description, always = always}} -- 197
end -- 167
____exports.SkillsLoader = __TS__Class() -- 206
local SkillsLoader = ____exports.SkillsLoader -- 206
SkillsLoader.name = "SkillsLoader" -- 206
function SkillsLoader.prototype.____constructor(self, config) -- 211
	self.skills = __TS__New(Map) -- 208
	self.loaded = false -- 209
	self.config = config -- 212
end -- 211
function SkillsLoader.prototype.load(self) -- 215
	self.skills:clear() -- 216
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 218
	local builtInParent = Content.assetPath -- 219
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 220
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 222
	local userParent = Content.writablePath -- 223
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 224
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 226
	local projectParent = self.config.projectDir -- 227
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 228
	self.loaded = true -- 230
	Log( -- 231
		"Info", -- 231
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 231
	) -- 231
end -- 215
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 234
	if not Content:exist(dir) or not Content:isdir(dir) then -- 234
		return -- 236
	end -- 236
	local subdirs = Content:getDirs(dir) -- 239
	if not subdirs or #subdirs == 0 then -- 239
		return -- 241
	end -- 241
	for ____, subdir in ipairs(subdirs) do -- 244
		do -- 244
			local skillPath = Path(dir, subdir, "SKILL.md") -- 245
			if not Content:exist(skillPath) then -- 245
				goto __continue37 -- 247
			end -- 247
			local skill = self:loadSkillFile(skillPath) -- 250
			if not skill then -- 250
				goto __continue37 -- 252
			end -- 252
			skill.location = Path:getRelative(skillPath, parent) -- 255
			local existing = self.skills:get(skill.name) -- 257
			if existing and existing.priority >= priority then -- 257
				goto __continue37 -- 259
			end -- 259
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 262
		end -- 262
		::__continue37:: -- 262
	end -- 262
end -- 234
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 266
	local content = Content:load(skillPath) -- 267
	if not content then -- 267
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 269
		return nil -- 270
	end -- 270
	local parsed = parseYAMLFrontmatter(content) -- 273
	local validated = validateSkillMetadata(parsed.metadata) -- 274
	if validated.error then -- 274
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 277
		return nil -- 278
	end -- 278
	local displayLocation = skillPath -- 281
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 281
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 283
	end -- 283
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 286
	return skill -- 292
end -- 266
function SkillsLoader.prototype.getAllSkills(self) -- 295
	if not self.loaded then -- 295
		self:load() -- 297
	end -- 297
	local result = {} -- 300
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 301
		result[#result + 1] = entry.skill -- 302
	end -- 302
	__TS__ArraySort( -- 305
		result, -- 305
		function(____, a, b) -- 305
			if a.name < b.name then -- 305
				return -1 -- 307
			end -- 307
			if a.name > b.name then -- 307
				return 1 -- 310
			end -- 310
			if a.location < b.location then -- 310
				return -1 -- 313
			end -- 313
			if a.location > b.location then -- 313
				return 1 -- 316
			end -- 316
			return 0 -- 318
		end -- 305
	) -- 305
	return result -- 321
end -- 295
function SkillsLoader.prototype.getSkill(self, name) -- 324
	if not self.loaded then -- 324
		self:load() -- 326
	end -- 326
	local ____opt_0 = self.skills:get(name) -- 326
	return ____opt_0 and ____opt_0.skill -- 329
end -- 324
function SkillsLoader.prototype.getAlwaysSkills(self) -- 332
	local all = self:getAllSkills() -- 333
	return __TS__ArrayFilter( -- 334
		all, -- 334
		function(____, skill) return skill.always == true end -- 334
	) -- 334
end -- 332
function SkillsLoader.prototype.getSummarySkills(self) -- 337
	local all = self:getAllSkills() -- 338
	return __TS__ArrayFilter( -- 339
		all, -- 339
		function(____, skill) return skill.always ~= true end -- 339
	) -- 339
end -- 337
function SkillsLoader.prototype.buildLevel1Summary(self) -- 342
	local skills = self:getSummarySkills() -- 343
	if #skills == 0 then -- 343
		return "" -- 346
	end -- 346
	local parts = {} -- 349
	for ____, skill in ipairs(skills) do -- 351
		local skillXML = "<skill>\n" -- 352
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 353
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 354
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 355
		skillXML = skillXML .. "</skill>" -- 356
		parts[#parts + 1] = skillXML -- 357
	end -- 357
	return table.concat(parts, "\n\n") -- 360
end -- 342
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 363
	local skills = self:getAlwaysSkills() -- 364
	if #skills == 0 then -- 364
		return "" -- 367
	end -- 367
	local parts = {} -- 370
	for ____, skill in ipairs(skills) do -- 372
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 373
		if skill.description ~= nil then -- 373
			parts[#parts + 1] = skill.description .. "\n" -- 375
		end -- 375
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 375
			parts[#parts + 1] = "\n" .. skill.body -- 378
		end -- 378
		parts[#parts + 1] = "" -- 380
	end -- 380
	return table.concat(parts, "\n") -- 383
end -- 363
function SkillsLoader.prototype.loadSkillContent(self, name) -- 386
	local skill = self:getSkill(name) -- 387
	if not skill then -- 387
		return nil -- 389
	end -- 389
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 389
		return skill.body -- 393
	end -- 393
	local content = Content:load(skill.location) -- 396
	if not content then -- 396
		return nil -- 398
	end -- 398
	local parsed = parseYAMLFrontmatter(content) -- 401
	if parsed.body == "" then -- 401
		return nil -- 403
	end -- 403
	return parsed.body -- 405
end -- 386
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 408
	if not self.loaded then -- 408
		self:load() -- 410
	end -- 410
	local sections = {} -- 413
	local activeContent = self:buildActiveSkillsContent() -- 415
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 416
	local summary = self:buildLevel1Summary() -- 418
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 419
	return table.concat(sections, "\n\n---\n\n")
end -- 408
function SkillsLoader.prototype.escapeXML(self, text) -- 424
	return escapeXMLText(text) -- 425
end -- 424
function SkillsLoader.prototype.reload(self) -- 428
	self.loaded = false -- 429
	self:load() -- 430
end -- 428
function SkillsLoader.prototype.getSkillCount(self) -- 433
	if not self.loaded then -- 433
		self:load() -- 435
	end -- 435
	return self.skills.size -- 437
end -- 433
function ____exports.createSkillsLoader(config) -- 441
	return __TS__New(____exports.SkillsLoader, config) -- 442
end -- 441
return ____exports -- 441