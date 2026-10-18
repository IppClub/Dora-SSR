-- [ts]: LLMConfigNames.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local DB = ____Dora.DB -- 2
local VERSION_KEY = "agentLLMConfigNamesVersion" -- 5
local VERSION = 1 -- 6
function ____exports.normalizeLLMConfigName(value) -- 8
	if type(value) ~= "string" then -- 8
		return nil -- 9
	end -- 9
	local name = __TS__StringTrim(value) -- 10
	local ____temp_0 -- 11
	if name == "" then -- 11
		____temp_0 = nil -- 11
	else -- 11
		____temp_0 = name -- 11
	end -- 11
	return ____temp_0 -- 11
end -- 8
function ____exports.upgradeLLMConfigNames() -- 14
	local versions = DB:query("SELECT value_num FROM Config WHERE name = ?", {VERSION_KEY}) -- 15
	if not versions then -- 15
		error("Failed to read LLM configuration name version") -- 16
	end -- 16
	local ____tonumber_3 = tonumber -- 17
	local ____opt_1 = versions[1] -- 17
	if (____tonumber_3(____opt_1 and ____opt_1[1]) or 0) >= VERSION then -- 17
		return -- 17
	end -- 17
	local rows = DB:query("SELECT id, name FROM LLMConfig ORDER BY id") -- 18
	if not rows then -- 18
		error("Failed to read LLM configuration names") -- 19
	end -- 19
	local reserved = {} -- 20
	local occupied = {} -- 21
	for ____, row in ipairs(rows) do -- 22
		occupied[tostring(row[2])] = true -- 23
		local name = ____exports.normalizeLLMConfigName(row[2]) -- 24
		if name ~= nil then -- 24
			reserved[name] = true -- 25
		end -- 25
	end -- 25
	local assigned = {} -- 27
	local suffixes = {} -- 28
	local changes = {} -- 29
	for ____, row in ipairs(rows) do -- 30
		local original = row[2] -- 31
		local normalized = ____exports.normalizeLLMConfigName(original) -- 32
		local base = normalized or "Model" -- 33
		local name = base -- 34
		if assigned[name] or normalized == nil and reserved[name] then -- 34
			local suffix = suffixes[base] or 2 -- 36
			repeat -- 36
				do -- 36
					local ____suffix_4 = suffix -- 36
					suffix = ____suffix_4 + 1 -- 37
					name = ((base .. " (") .. tostring(____suffix_4)) .. ")" -- 37
				end -- 37
			until not (reserved[name] or assigned[name]) -- 37
			suffixes[base] = suffix -- 38
		end -- 38
		assigned[name] = true -- 40
		occupied[name] = true -- 41
		if name ~= original then -- 41
			changes[#changes + 1] = {id = row[1], name = name} -- 42
		end -- 42
	end -- 42
	local updates = {} -- 45
	for ____, change in ipairs(changes) do -- 47
		local temporary = ("__dora_llm_name_" .. tostring(change.id)) .. "__" -- 48
		while occupied[temporary] do -- 48
			temporary = temporary .. "_" -- 49
		end -- 49
		occupied[temporary] = true -- 50
		updates[#updates + 1] = {"UPDATE LLMConfig SET name = ? WHERE id = ?", {{temporary, change.id}}} -- 51
	end -- 51
	for ____, change in ipairs(changes) do -- 53
		updates[#updates + 1] = {"UPDATE LLMConfig SET name = ? WHERE id = ?", {{change.name, change.id}}} -- 54
	end -- 54
	updates[#updates + 1] = "CREATE UNIQUE INDEX IF NOT EXISTS idx_llm_config_name ON LLMConfig(name)" -- 56
	updates[#updates + 1] = {"INSERT OR REPLACE INTO Config(name, value_num, value_str, value_bool) VALUES(?, ?, NULL, NULL)", {{VERSION_KEY, VERSION}}} -- 57
	if not DB:transaction(updates) then -- 57
		error("Failed to upgrade LLM configuration names") -- 58
	end -- 58
end -- 14
function ____exports.checkLLMConfigName(name, excludeId) -- 61
	if excludeId == nil then -- 61
		excludeId = 0 -- 61
	end -- 61
	local rows = DB:query("SELECT id FROM LLMConfig WHERE name = ? AND id <> ? LIMIT 1", {name, excludeId}) -- 62
	if not rows then -- 62
		return {success = false, code = "LLM_CONFIG_NAME_CHECK_FAILED", message = "Failed to check LLM configuration name"} -- 63
	end -- 63
	if #rows > 0 then -- 63
		return {success = false, code = "LLM_CONFIG_NAME_EXISTS", message = "LLM configuration name already exists"} -- 64
	end -- 64
	return {success = true} -- 65
end -- 61
return ____exports -- 61