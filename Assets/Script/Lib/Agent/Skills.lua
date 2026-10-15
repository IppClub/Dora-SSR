-- [ts]: Skills.ts
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
function normalizeStringList(value) -- 230
	if type(value) == "string" then -- 230
		local trimmed = __TS__StringTrim(value) -- 232
		local ____temp_0 -- 233
		if trimmed == "" then -- 233
			____temp_0 = nil -- 233
		else -- 233
			____temp_0 = {trimmed} -- 233
		end -- 233
		return ____temp_0 -- 233
	end -- 233
	if not __TS__ArrayIsArray(value) then -- 233
		return nil -- 236
	end -- 236
	local result = {} -- 238
	for ____, item in ipairs(value) do -- 239
		do -- 239
			if type(item) ~= "string" then -- 239
				goto __continue39 -- 241
			end -- 241
			local trimmed = __TS__StringTrim(item) -- 243
			if trimmed ~= "" and __TS__ArrayIndexOf(result, trimmed) < 0 then -- 243
				result[#result + 1] = trimmed -- 245
			end -- 245
		end -- 245
		::__continue39:: -- 245
	end -- 245
	return #result > 0 and result or nil -- 248
end -- 248
local SkillPriority = SkillPriority or ({}) -- 27
SkillPriority.BuiltIn = 0 -- 28
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 28
SkillPriority.User = 1 -- 29
SkillPriority[SkillPriority.User] = "User" -- 29
SkillPriority.Project = 2 -- 30
SkillPriority[SkillPriority.Project] = "Project" -- 30
local function stripWrappingQuotes(value) -- 38
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 39
	result = string.gsub(result, "^'(.*)'$", "%1") -- 40
	return result -- 41
end -- 38
local function escapeXMLText(text) -- 44
	local result = string.gsub(text, "&", "&amp;") -- 45
	result = string.gsub(result, "<", "&lt;") -- 46
	result = string.gsub(result, ">", "&gt;") -- 47
	result = string.gsub(result, "\"", "&quot;") -- 48
	result = string.gsub(result, "'", "&apos;") -- 49
	return result -- 50
end -- 44
local function parseSimpleYAML(text) -- 53
	if __TS__StringTrim(text) == "" then -- 53
		return nil -- 55
	end -- 55
	local result = {} -- 58
	local lines = __TS__StringSplit(text, "\n") -- 59
	local currentKey = "" -- 60
	local currentArray = nil -- 61
	do -- 61
		local i = 0 -- 63
		while i < #lines do -- 63
			do -- 63
				local line = lines[i + 1] -- 64
				local trimmed = __TS__StringTrim(line) -- 65
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 65
					goto __continue7 -- 68
				end -- 68
				if __TS__StringStartsWith(trimmed, "- ") then -- 68
					if currentArray ~= nil and currentKey ~= "" then -- 68
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 73
						local cleaned = stripWrappingQuotes(value) -- 74
						currentArray[#currentArray + 1] = cleaned -- 75
					end -- 75
					goto __continue7 -- 77
				end -- 77
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 80
				if colonIndex > 0 then -- 80
					if currentArray ~= nil and currentKey ~= "" then -- 80
						result[currentKey] = currentArray -- 83
						currentArray = nil -- 84
					end -- 84
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 87
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 88
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 88
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 91
						local items = value == "[]" and ({}) or __TS__ArrayMap( -- 92
							__TS__StringSplit(arrayText, ","), -- 94
							function(____, item) return stripWrappingQuotes(__TS__StringTrim(item)) end -- 94
						) -- 94
						result[key] = items -- 95
						goto __continue7 -- 96
					end -- 96
					if value == "true" then -- 96
						result[key] = true -- 100
						goto __continue7 -- 101
					end -- 101
					if value == "false" then -- 101
						result[key] = false -- 104
						goto __continue7 -- 105
					end -- 105
					if value == "" then -- 105
						currentKey = key -- 109
						currentArray = {} -- 110
						if i + 1 < #lines then -- 110
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 112
							if not __TS__StringStartsWith(nextLine, "- ") then -- 112
								currentArray = nil -- 114
								result[key] = "" -- 115
							end -- 115
						else -- 115
							currentArray = nil -- 118
							result[key] = "" -- 119
						end -- 119
						goto __continue7 -- 121
					end -- 121
					local cleaned = stripWrappingQuotes(value) -- 124
					result[key] = cleaned -- 125
					currentKey = "" -- 126
					currentArray = nil -- 127
				end -- 127
			end -- 127
			::__continue7:: -- 127
			i = i + 1 -- 63
		end -- 63
	end -- 63
	if currentArray ~= nil and currentKey ~= "" then -- 63
		result[currentKey] = currentArray -- 132
	end -- 132
	return result -- 135
end -- 53
local function parseYAMLFrontmatter(content) -- 138
	if __TS__StringTrim(content) == "" then -- 138
		return {metadata = nil, body = "", error = "empty content"} -- 144
	end -- 144
	local trimmed = __TS__StringTrim(content) -- 147
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 149
	end -- 149
	local lines = __TS__StringSplit(trimmed, "\n") -- 152
	local endLine = -1 -- 153
	do -- 153
		local i = 1 -- 154
		while i < #lines do -- 154
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 156
				break -- 157
			end -- 157
			i = i + 1 -- 154
		end -- 154
	end -- 154
	if endLine < 0 then -- 154
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 162
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 165
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 166
	local metadata = parseSimpleYAML(frontmatterText) -- 167
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 168
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 169
	return {metadata = metadata, body = body} -- 171
end -- 138
local function validateSkillMetadata(metadata) -- 174
	if not metadata then -- 174
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 178
	end -- 178
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 187
	if name == "" then -- 187
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 189
	end -- 189
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 198
	local always = metadata.always == true -- 202
	local requiredTools = normalizeStringList(metadata.requiredTools) -- 203
	local rawWorkModes = normalizeStringList(metadata.workModes) -- 204
	local workModes = nil -- 205
	if rawWorkModes ~= nil then -- 205
		workModes = {} -- 207
		for ____, mode in ipairs(rawWorkModes) do -- 208
			if mode ~= "code" and mode ~= "plan" then -- 208
				return {metadata = {name = name, description = description, always = always, requiredTools = requiredTools}, error = "invalid work mode in frontmatter: " .. mode} -- 210
			end -- 210
			workModes[#workModes + 1] = mode -- 215
		end -- 215
	end -- 215
	return {metadata = { -- 219
		name = name, -- 221
		description = description, -- 222
		always = always, -- 223
		requiredTools = requiredTools, -- 224
		workModes = workModes -- 225
	}} -- 225
end -- 174
____exports.SkillsLoader = __TS__Class() -- 251
local SkillsLoader = ____exports.SkillsLoader -- 251
SkillsLoader.name = "SkillsLoader" -- 251
function SkillsLoader.prototype.____constructor(self, config) -- 256
	self.skills = __TS__New(Map) -- 253
	self.loaded = false -- 254
	self.config = config -- 257
end -- 256
function SkillsLoader.prototype.load(self) -- 260
	self.skills:clear() -- 261
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 263
	self:loadSkillsFromDir(builtInDir, SkillPriority.BuiltIn) -- 264
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 266
	self:loadSkillsFromDir(userDir, SkillPriority.User) -- 267
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 269
	self:loadSkillsFromDir(projectDir, SkillPriority.Project) -- 270
	self.loaded = true -- 272
	Log( -- 273
		"Info", -- 273
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 273
	) -- 273
end -- 260
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, priority) -- 276
	if not Content:exist(dir) or not Content:isdir(dir) then -- 276
		return -- 278
	end -- 278
	local subdirs = Content:getDirs(dir) -- 281
	if #subdirs == 0 then -- 281
		return -- 283
	end -- 283
	for ____, subdir in ipairs(subdirs) do -- 286
		do -- 286
			local skillPath = Path(dir, subdir, "SKILL.md") -- 287
			if not Content:exist(skillPath) then -- 287
				goto __continue48 -- 289
			end -- 289
			local skill = self:loadSkillFile(skillPath) -- 292
			if not skill then -- 292
				goto __continue48 -- 294
			end -- 294
			local relative = table.concat( -- 297
				__TS__StringSplit( -- 297
					Path:getRelative(skillPath, dir), -- 297
					"\\" -- 297
				), -- 297
				"/" -- 297
			) -- 297
			skill.location = priority == SkillPriority.BuiltIn and "@agent-skill/builtin/" .. relative or (priority == SkillPriority.User and "@agent-skill/user/" .. relative or ".agent/skills/" .. relative) -- 298
			local existing = self.skills:get(skill.name) -- 304
			if existing and existing.priority >= priority then -- 304
				goto __continue48 -- 306
			end -- 306
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 309
		end -- 309
		::__continue48:: -- 309
	end -- 309
end -- 276
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 313
	local content = Content:load(skillPath) -- 314
	if type(content) ~= "string" or content == "" then -- 314
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 316
		return nil -- 317
	end -- 317
	local parsed = parseYAMLFrontmatter(content) -- 320
	local validated = validateSkillMetadata(parsed.metadata) -- 321
	if validated.error then -- 321
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 324
		return nil -- 325
	end -- 325
	local displayLocation = skillPath -- 328
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 328
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 330
	end -- 330
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, sourcePath = skillPath, body = parsed.body}) -- 333
	return skill -- 340
end -- 313
function SkillsLoader.prototype.getAllSkills(self) -- 343
	if not self.loaded then -- 343
		self:load() -- 345
	end -- 345
	local result = {} -- 348
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 349
		do -- 349
			if not self:isSkillEnabled(entry.skill) then -- 349
				goto __continue59 -- 351
			end -- 351
			result[#result + 1] = entry.skill -- 353
		end -- 353
		::__continue59:: -- 353
	end -- 353
	__TS__ArraySort( -- 356
		result, -- 356
		function(____, a, b) -- 356
			if a.name < b.name then -- 356
				return -1 -- 358
			end -- 358
			if a.name > b.name then -- 358
				return 1 -- 361
			end -- 361
			if a.location < b.location then -- 361
				return -1 -- 364
			end -- 364
			if a.location > b.location then -- 364
				return 1 -- 367
			end -- 367
			return 0 -- 369
		end -- 356
	) -- 356
	return result -- 372
end -- 343
function SkillsLoader.prototype.getSkill(self, name) -- 375
	if not self.loaded then -- 375
		self:load() -- 377
	end -- 377
	local ____opt_1 = self.skills:get(name) -- 377
	local skill = ____opt_1 and ____opt_1.skill -- 380
	if not skill or not self:isSkillEnabled(skill) then -- 380
		return nil -- 382
	end -- 382
	return skill -- 384
end -- 375
function SkillsLoader.prototype.getAlwaysSkills(self) -- 387
	local all = self:getAllSkills() -- 388
	return __TS__ArrayFilter( -- 389
		all, -- 389
		function(____, skill) return skill.always == true end -- 389
	) -- 389
end -- 387
function SkillsLoader.prototype.getSummarySkills(self) -- 392
	local all = self:getAllSkills() -- 393
	return __TS__ArrayFilter( -- 394
		all, -- 394
		function(____, skill) return skill.always ~= true end -- 394
	) -- 394
end -- 392
function SkillsLoader.prototype.buildLevel1Summary(self) -- 397
	local skills = self:getSummarySkills() -- 398
	if #skills == 0 then -- 398
		return "" -- 401
	end -- 401
	local parts = {} -- 404
	for ____, skill in ipairs(skills) do -- 406
		local skillXML = "<skill>\n" -- 407
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 408
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 409
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 410
		skillXML = skillXML .. "</skill>" -- 411
		parts[#parts + 1] = skillXML -- 412
	end -- 412
	return table.concat(parts, "\n\n") -- 415
end -- 397
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 418
	local skills = self:getAlwaysSkills() -- 419
	if #skills == 0 then -- 419
		return "" -- 422
	end -- 422
	local parts = {} -- 425
	for ____, skill in ipairs(skills) do -- 427
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 428
		if skill.description ~= nil then -- 428
			parts[#parts + 1] = skill.description .. "\n" -- 430
		end -- 430
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 430
			parts[#parts + 1] = "\n" .. skill.body -- 433
		end -- 433
		parts[#parts + 1] = "" -- 435
	end -- 435
	return table.concat(parts, "\n") -- 438
end -- 418
function SkillsLoader.prototype.loadSkillContent(self, name) -- 441
	local skill = self:getSkill(name) -- 442
	if not skill then -- 442
		return nil -- 444
	end -- 444
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 444
		return skill.body -- 448
	end -- 448
	local content = Content:load(skill.sourcePath) -- 451
	if type(content) ~= "string" or content == "" then -- 451
		return nil -- 453
	end -- 453
	local parsed = parseYAMLFrontmatter(content) -- 456
	if parsed.body == "" then -- 456
		return nil -- 458
	end -- 458
	return parsed.body -- 460
end -- 441
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 463
	if not self.loaded then -- 463
		self:load() -- 465
	end -- 465
	local sections = {} -- 468
	local activeContent = self:buildActiveSkillsContent() -- 470
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 471
	local summary = self:buildLevel1Summary() -- 473
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 474
	return table.concat(sections, "\n\n---\n\n")
end -- 463
function SkillsLoader.prototype.escapeXML(self, text) -- 479
	return escapeXMLText(text) -- 480
end -- 479
function SkillsLoader.prototype.isSkillEnabled(self, skill) -- 483
	local workModes = skill.workModes or ({}) -- 484
	if #workModes > 0 and __TS__ArrayIndexOf(workModes, self.config.workMode or "code") < 0 then -- 484
		return false -- 486
	end -- 486
	local requiredTools = skill.requiredTools or ({}) -- 488
	if #requiredTools == 0 then -- 488
		return true -- 490
	end -- 490
	local disabledTools = self.config.disabledAgentTools or ({}) -- 492
	local allowedTools = self.config.allowedAgentTools -- 493
	for ____, tool in ipairs(requiredTools) do -- 494
		if __TS__ArrayIndexOf(disabledTools, tool) >= 0 then -- 494
			return false -- 496
		end -- 496
		if allowedTools ~= nil and __TS__ArrayIndexOf(allowedTools, tool) < 0 then -- 496
			return false -- 498
		end -- 498
	end -- 498
	return true -- 500
end -- 483
function SkillsLoader.prototype.reload(self) -- 503
	self.loaded = false -- 504
	self:load() -- 505
end -- 503
function SkillsLoader.prototype.getSkillCount(self) -- 508
	if not self.loaded then -- 508
		self:load() -- 510
	end -- 510
	return self.skills.size -- 512
end -- 508
function ____exports.createSkillsLoader(config) -- 516
	return __TS__New(____exports.SkillsLoader, config) -- 517
end -- 516
return ____exports -- 516