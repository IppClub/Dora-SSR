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
function normalizeStringList(value) -- 210
	if type(value) == "string" then -- 210
		local trimmed = __TS__StringTrim(value) -- 212
		local ____temp_0 -- 213
		if trimmed == "" then -- 213
			____temp_0 = nil -- 213
		else -- 213
			____temp_0 = {trimmed} -- 213
		end -- 213
		return ____temp_0 -- 213
	end -- 213
	if not __TS__ArrayIsArray(value) then -- 213
		return nil -- 216
	end -- 216
	local result = {} -- 218
	for ____, item in ipairs(value) do -- 219
		do -- 219
			if type(item) ~= "string" then -- 219
				goto __continue35 -- 221
			end -- 221
			local trimmed = __TS__StringTrim(item) -- 223
			if trimmed ~= "" and __TS__ArrayIndexOf(result, trimmed) < 0 then -- 223
				result[#result + 1] = trimmed -- 225
			end -- 225
		end -- 225
		::__continue35:: -- 225
	end -- 225
	return #result > 0 and result or nil -- 228
end -- 228
local SkillPriority = SkillPriority or ({}) -- 22
SkillPriority.BuiltIn = 0 -- 23
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 23
SkillPriority.User = 1 -- 24
SkillPriority[SkillPriority.User] = "User" -- 24
SkillPriority.Project = 2 -- 25
SkillPriority[SkillPriority.Project] = "Project" -- 25
local function stripWrappingQuotes(value) -- 33
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 34
	result = string.gsub(result, "^'(.*)'$", "%1") -- 35
	return result -- 36
end -- 33
local function escapeXMLText(text) -- 39
	local result = string.gsub(text, "&", "&amp;") -- 40
	result = string.gsub(result, "<", "&lt;") -- 41
	result = string.gsub(result, ">", "&gt;") -- 42
	result = string.gsub(result, "\"", "&quot;") -- 43
	result = string.gsub(result, "'", "&apos;") -- 44
	return result -- 45
end -- 39
local function parseSimpleYAML(text) -- 48
	if not text or __TS__StringTrim(text) == "" then -- 48
		return nil -- 50
	end -- 50
	local result = {} -- 53
	local lines = __TS__StringSplit(text, "\n") -- 54
	local currentKey = "" -- 55
	local currentArray = nil -- 56
	do -- 56
		local i = 0 -- 58
		while i < #lines do -- 58
			do -- 58
				local line = lines[i + 1] -- 59
				local trimmed = __TS__StringTrim(line) -- 60
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 60
					goto __continue7 -- 63
				end -- 63
				if __TS__StringStartsWith(trimmed, "- ") then -- 63
					if currentArray ~= nil and currentKey ~= "" then -- 63
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 68
						local cleaned = stripWrappingQuotes(value) -- 69
						currentArray[#currentArray + 1] = cleaned -- 70
					end -- 70
					goto __continue7 -- 72
				end -- 72
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 75
				if colonIndex > 0 then -- 75
					if currentArray ~= nil and currentKey ~= "" then -- 75
						result[currentKey] = currentArray -- 78
						currentArray = nil -- 79
					end -- 79
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 82
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 83
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 83
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 86
						local items = value == "[]" and ({}) or __TS__ArrayMap( -- 87
							__TS__StringSplit(arrayText, ","), -- 89
							function(____, item) return stripWrappingQuotes(__TS__StringTrim(item)) end -- 89
						) -- 89
						result[key] = items -- 90
						goto __continue7 -- 91
					end -- 91
					if value == "true" then -- 91
						result[key] = true -- 95
						goto __continue7 -- 96
					end -- 96
					if value == "false" then -- 96
						result[key] = false -- 99
						goto __continue7 -- 100
					end -- 100
					if value == "" then -- 100
						currentKey = key -- 104
						currentArray = {} -- 105
						if i + 1 < #lines then -- 105
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 107
							if not __TS__StringStartsWith(nextLine, "- ") then -- 107
								currentArray = nil -- 109
								result[key] = "" -- 110
							end -- 110
						else -- 110
							currentArray = nil -- 113
							result[key] = "" -- 114
						end -- 114
						goto __continue7 -- 116
					end -- 116
					local cleaned = stripWrappingQuotes(value) -- 119
					result[key] = cleaned -- 120
					currentKey = "" -- 121
					currentArray = nil -- 122
				end -- 122
			end -- 122
			::__continue7:: -- 122
			i = i + 1 -- 58
		end -- 58
	end -- 58
	if currentArray ~= nil and currentKey ~= "" then -- 58
		result[currentKey] = currentArray -- 127
	end -- 127
	return result -- 130
end -- 48
local function parseYAMLFrontmatter(content) -- 133
	if not content or __TS__StringTrim(content) == "" then -- 133
		return {metadata = nil, body = "", error = "empty content"} -- 139
	end -- 139
	local trimmed = __TS__StringTrim(content) -- 142
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 144
	end -- 144
	local lines = __TS__StringSplit(trimmed, "\n") -- 147
	local endLine = -1 -- 148
	do -- 148
		local i = 1 -- 149
		while i < #lines do -- 149
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 151
				break -- 152
			end -- 152
			i = i + 1 -- 149
		end -- 149
	end -- 149
	if endLine < 0 then -- 149
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 157
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 160
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 161
	local metadata = parseSimpleYAML(frontmatterText) -- 162
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 163
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 164
	return {metadata = metadata, body = body} -- 166
end -- 133
local function validateSkillMetadata(metadata) -- 169
	if not metadata then -- 169
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 173
	end -- 173
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 182
	if name == "" then -- 182
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 184
	end -- 184
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 193
	local always = metadata.always == true -- 197
	local requiredTools = normalizeStringList(metadata.requiredTools) -- 198
	return {metadata = {name = name, description = description, always = always, requiredTools = requiredTools}} -- 200
end -- 169
____exports.SkillsLoader = __TS__Class() -- 231
local SkillsLoader = ____exports.SkillsLoader -- 231
SkillsLoader.name = "SkillsLoader" -- 231
function SkillsLoader.prototype.____constructor(self, config) -- 236
	self.skills = __TS__New(Map) -- 233
	self.loaded = false -- 234
	self.config = config -- 237
end -- 236
function SkillsLoader.prototype.load(self) -- 240
	self.skills:clear() -- 241
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 243
	local builtInParent = Content.assetPath -- 244
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 245
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 247
	local userParent = Content.writablePath -- 248
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 249
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 251
	local projectParent = self.config.projectDir -- 252
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 253
	self.loaded = true -- 255
	Log( -- 256
		"Info", -- 256
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 256
	) -- 256
end -- 240
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 259
	if not Content:exist(dir) or not Content:isdir(dir) then -- 259
		return -- 261
	end -- 261
	local subdirs = Content:getDirs(dir) -- 264
	if not subdirs or #subdirs == 0 then -- 264
		return -- 266
	end -- 266
	for ____, subdir in ipairs(subdirs) do -- 269
		do -- 269
			local skillPath = Path(dir, subdir, "SKILL.md") -- 270
			if not Content:exist(skillPath) then -- 270
				goto __continue44 -- 272
			end -- 272
			local skill = self:loadSkillFile(skillPath) -- 275
			if not skill then -- 275
				goto __continue44 -- 277
			end -- 277
			skill.location = Path:getRelative(skillPath, parent) -- 280
			local existing = self.skills:get(skill.name) -- 282
			if existing and existing.priority >= priority then -- 282
				goto __continue44 -- 284
			end -- 284
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 287
		end -- 287
		::__continue44:: -- 287
	end -- 287
end -- 259
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 291
	local content = Content:load(skillPath) -- 292
	if not content then -- 292
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 294
		return nil -- 295
	end -- 295
	local parsed = parseYAMLFrontmatter(content) -- 298
	local validated = validateSkillMetadata(parsed.metadata) -- 299
	if validated.error then -- 299
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 302
		return nil -- 303
	end -- 303
	local displayLocation = skillPath -- 306
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 306
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 308
	end -- 308
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 311
	return skill -- 317
end -- 291
function SkillsLoader.prototype.getAllSkills(self) -- 320
	if not self.loaded then -- 320
		self:load() -- 322
	end -- 322
	local result = {} -- 325
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 326
		do -- 326
			if not self:isSkillEnabled(entry.skill) then -- 326
				goto __continue55 -- 328
			end -- 328
			result[#result + 1] = entry.skill -- 330
		end -- 330
		::__continue55:: -- 330
	end -- 330
	__TS__ArraySort( -- 333
		result, -- 333
		function(____, a, b) -- 333
			if a.name < b.name then -- 333
				return -1 -- 335
			end -- 335
			if a.name > b.name then -- 335
				return 1 -- 338
			end -- 338
			if a.location < b.location then -- 338
				return -1 -- 341
			end -- 341
			if a.location > b.location then -- 341
				return 1 -- 344
			end -- 344
			return 0 -- 346
		end -- 333
	) -- 333
	return result -- 349
end -- 320
function SkillsLoader.prototype.getSkill(self, name) -- 352
	if not self.loaded then -- 352
		self:load() -- 354
	end -- 354
	local ____opt_1 = self.skills:get(name) -- 354
	local skill = ____opt_1 and ____opt_1.skill -- 357
	if not skill or not self:isSkillEnabled(skill) then -- 357
		return nil -- 359
	end -- 359
	return skill -- 361
end -- 352
function SkillsLoader.prototype.getAlwaysSkills(self) -- 364
	local all = self:getAllSkills() -- 365
	return __TS__ArrayFilter( -- 366
		all, -- 366
		function(____, skill) return skill.always == true end -- 366
	) -- 366
end -- 364
function SkillsLoader.prototype.getSummarySkills(self) -- 369
	local all = self:getAllSkills() -- 370
	return __TS__ArrayFilter( -- 371
		all, -- 371
		function(____, skill) return skill.always ~= true end -- 371
	) -- 371
end -- 369
function SkillsLoader.prototype.buildLevel1Summary(self) -- 374
	local skills = self:getSummarySkills() -- 375
	if #skills == 0 then -- 375
		return "" -- 378
	end -- 378
	local parts = {} -- 381
	for ____, skill in ipairs(skills) do -- 383
		local skillXML = "<skill>\n" -- 384
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 385
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 386
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 387
		skillXML = skillXML .. "</skill>" -- 388
		parts[#parts + 1] = skillXML -- 389
	end -- 389
	return table.concat(parts, "\n\n") -- 392
end -- 374
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 395
	local skills = self:getAlwaysSkills() -- 396
	if #skills == 0 then -- 396
		return "" -- 399
	end -- 399
	local parts = {} -- 402
	for ____, skill in ipairs(skills) do -- 404
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 405
		if skill.description ~= nil then -- 405
			parts[#parts + 1] = skill.description .. "\n" -- 407
		end -- 407
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 407
			parts[#parts + 1] = "\n" .. skill.body -- 410
		end -- 410
		parts[#parts + 1] = "" -- 412
	end -- 412
	return table.concat(parts, "\n") -- 415
end -- 395
function SkillsLoader.prototype.loadSkillContent(self, name) -- 418
	local skill = self:getSkill(name) -- 419
	if not skill then -- 419
		return nil -- 421
	end -- 421
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 421
		return skill.body -- 425
	end -- 425
	local content = Content:load(skill.location) -- 428
	if not content then -- 428
		return nil -- 430
	end -- 430
	local parsed = parseYAMLFrontmatter(content) -- 433
	if parsed.body == "" then -- 433
		return nil -- 435
	end -- 435
	return parsed.body -- 437
end -- 418
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 440
	if not self.loaded then -- 440
		self:load() -- 442
	end -- 442
	local sections = {} -- 445
	local activeContent = self:buildActiveSkillsContent() -- 447
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 448
	local summary = self:buildLevel1Summary() -- 450
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 451
	return table.concat(sections, "\n\n---\n\n")
end -- 440
function SkillsLoader.prototype.escapeXML(self, text) -- 456
	return escapeXMLText(text) -- 457
end -- 456
function SkillsLoader.prototype.isSkillEnabled(self, skill) -- 460
	local requiredTools = skill.requiredTools or ({}) -- 461
	if #requiredTools == 0 then -- 461
		return true -- 463
	end -- 463
	local disabledTools = self.config.disabledAgentTools or ({}) -- 465
	for ____, tool in ipairs(requiredTools) do -- 466
		if __TS__ArrayIndexOf(disabledTools, tool) >= 0 then -- 466
			return false -- 468
		end -- 468
	end -- 468
	return true -- 471
end -- 460
function SkillsLoader.prototype.reload(self) -- 474
	self.loaded = false -- 475
	self:load() -- 476
end -- 474
function SkillsLoader.prototype.getSkillCount(self) -- 479
	if not self.loaded then -- 479
		self:load() -- 481
	end -- 481
	return self.skills.size -- 483
end -- 479
function ____exports.createSkillsLoader(config) -- 487
	return __TS__New(____exports.SkillsLoader, config) -- 488
end -- 487
return ____exports -- 487