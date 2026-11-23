-- [ts]: TeamWake.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Content = ____Dora.Content -- 3
local Path = ____Dora.Path -- 3
____exports.TEAM_AGENT_TYPES = {"audio", "visual", "level", "test"} -- 5
function ____exports.buildTeamWakeContext(projectRoot, agentType) -- 7
	if __TS__ArrayIndexOf(____exports.TEAM_AGENT_TYPES, agentType) < 0 then -- 7
		return "" -- 8
	end -- 8
	local function readIfExists(path) -- 9
		if not Content:exist(path) then -- 9
			return "" -- 10
		end -- 10
		local text = Content:load(path) -- 11
		return type(text) == "string" and text or "" -- 12
	end -- 9
	local function truncateHead(text, maxLines, maxChars) -- 14
		if text == "" then -- 14
			return "" -- 15
		end -- 15
		local lines = __TS__StringSplit(text, "\n") -- 16
		local out = {} -- 17
		local total = 0 -- 18
		for ____, line in ipairs(lines) do -- 19
			total = total + (#line + 1) -- 20
			if #out >= maxLines or total > maxChars then -- 20
				out[#out + 1] = "... (truncated)" -- 22
				break -- 23
			end -- 23
			out[#out + 1] = line -- 25
		end -- 25
		return table.concat(out, "\n") -- 27
	end -- 14
	local sections = {} -- 29
	local profile = readIfExists(Path( -- 30
		projectRoot, -- 30
		".agent", -- 30
		"teams", -- 30
		agentType, -- 30
		"PROFILE.md" -- 30
	)) -- 30
	if __TS__StringTrim(profile) ~= "" then -- 30
		sections[#sections + 1] = (("# Team profile (.agent/teams/" .. agentType) .. "/PROFILE.md)\n") .. truncateHead( -- 32
			__TS__StringTrim(profile), -- 32
			60, -- 32
			6000 -- 32
		) -- 32
	end -- 32
	local assets = readIfExists(Path(projectRoot, ".agent", "main", "ASSETS.md")) -- 34
	if __TS__StringTrim(assets) ~= "" then -- 34
		sections[#sections + 1] = "# Shared asset state (.agent/main/ASSETS.md)\n" .. truncateHead( -- 36
			__TS__StringTrim(assets), -- 36
			60, -- 36
			6000 -- 36
		) -- 36
	end -- 36
	local memoryIndex = readIfExists(Path( -- 38
		projectRoot, -- 38
		".agent", -- 38
		"teams", -- 38
		agentType, -- 38
		"memory", -- 38
		"MEMORY.md" -- 38
	)) -- 38
	if __TS__StringTrim(memoryIndex) ~= "" then -- 38
		sections[#sections + 1] = (("# Team memory index (.agent/teams/" .. agentType) .. "/memory/MEMORY.md; topic files live next to it, read on demand)\n") .. truncateHead( -- 40
			__TS__StringTrim(memoryIndex), -- 40
			40, -- 40
			4000 -- 40
		) -- 40
	end -- 40
	sections[#sections + 1] = ("# Team memory protocol\nYou are a persistent team agent. This trigger is one engagement; the team memory in .agent/teams/" .. agentType) .. "/memory/ survives across triggers.\nMEMORY.md is an index with one line per entry; details belong in topic files next to it.\nWrite a memory only when one of these triggers fires; most runs should write nothing:\n- feedback: the user (often via the parent agent's task) corrected or confirmed a taste, style, or approach decision\n- project: a decision, constraint, or rationale not derivable from project files, ASSETS.md, or PROFILE.md\n- reference: where to find external resources (API keys, libraries, endpoints)\nNever store anything derivable from project files. When writing: append exactly one line to MEMORY.md, put details in a topic file, and if the index exceeds 40 lines, merge or drop stale entries first." -- 42
	return table.concat(sections, "\n\n---\n\n")
end -- 7
return ____exports -- 7