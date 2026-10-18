-- [ts]: LLMConfigMigration.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local DB = ____Dora.DB -- 2
local json = ____Dora.json -- 2
local Log = ____Dora.Log -- 2
local ____Defaults = require("Agent.Config.Defaults") -- 3
local AGENT_DEFAULTS = ____Defaults.AGENT_DEFAULTS -- 3
____exports.LLM_CONFIG_VERSION = 1 -- 6
local VERSION_KEY = "agentLLMConfigVersion" -- 7
function ____exports.upgradeLLMConfig() -- 9
	if not DB:exist("LLMConfig") then -- 9
		return -- 11
	end -- 11
	local versions = DB:query(("SELECT value_num FROM Config WHERE name = '" .. VERSION_KEY) .. "'") -- 12
	if not versions then -- 12
		error("Failed to read LLM configuration version") -- 13
	end -- 13
	local ____tonumber_2 = tonumber -- 14
	local ____opt_0 = versions[1] -- 14
	if (____tonumber_2(____opt_0 and ____opt_0[1]) or 0) >= ____exports.LLM_CONFIG_VERSION then -- 14
		return -- 14
	end -- 14
	local rows = DB:query("SELECT id, custom_options FROM LLMConfig") -- 15
	if not rows then -- 15
		error("Failed to read LLM configurations for upgrade") -- 16
	end -- 16
	local updates = {} -- 17
	local invalidOptions = 0 -- 18
	for ____, row in ipairs(rows) do -- 19
		do -- 19
			local ____tostring_4 = tostring -- 20
			local ____row__2_3 = row[2] -- 20
			if ____row__2_3 == nil then -- 20
				____row__2_3 = "" -- 20
			end -- 20
			local text = ____tostring_4(____row__2_3) -- 20
			if text == "" then -- 20
				goto __continue7 -- 21
			end -- 21
			local decoded = json.decode(text) -- 22
			if type(decoded) ~= "table" or decoded == json.null or (string.match(text, "^%s*{")) == nil then -- 22
				invalidOptions = invalidOptions + 1 -- 26
				goto __continue7 -- 27
			end -- 27
			local options = decoded -- 29
			local auxiliary = type(options.auxiliaryOptions) == "table" and options.auxiliaryOptions ~= json.null and options.auxiliaryOptions or nil -- 30
			if options.max_tokens == nil and options.max_completion_tokens == nil and (auxiliary and auxiliary.max_tokens) == nil and (auxiliary and auxiliary.max_completion_tokens) == nil then -- 30
				goto __continue7 -- 34
			end -- 34
			local completion = options.max_completion_tokens -- 35
			if completion ~= nil and completion ~= json.null then -- 35
				options.max_completion_tokens = AGENT_DEFAULTS.llmMaxTokens -- 36
			end -- 36
			if options.max_tokens ~= nil then -- 36
				if options.max_tokens ~= json.null then -- 36
					options.max_tokens = AGENT_DEFAULTS.llmMaxTokens -- 39
				elseif completion == nil or completion == json.null then -- 39
					__TS__Delete(options, "max_tokens") -- 40
				end -- 40
			end -- 40
			if auxiliary then -- 40
				__TS__Delete(auxiliary, "max_tokens") -- 43
				__TS__Delete(auxiliary, "max_completion_tokens") -- 44
			end -- 44
			local encoded, encodeError = json.encode(options) -- 46
			if not encoded then -- 46
				error(encodeError or "Failed to encode upgraded LLM custom options") -- 47
			end -- 47
			updates[#updates + 1] = {"UPDATE LLMConfig SET custom_options = ? WHERE id = ?", {{encoded, row[1]}}} -- 48
		end -- 48
		::__continue7:: -- 48
	end -- 48
	updates[#updates + 1] = "UPDATE LLMConfig SET max_tokens = " .. tostring(AGENT_DEFAULTS.llmMaxTokens) -- 51
	updates[#updates + 1] = ((("INSERT OR REPLACE INTO Config(name, value_num, value_str, value_bool) VALUES('" .. VERSION_KEY) .. "', ") .. tostring(____exports.LLM_CONFIG_VERSION)) .. ", NULL, NULL)" -- 52
	if not DB:transaction(updates) then -- 52
		error("Failed to upgrade LLM configurations") -- 53
	end -- 53
	if invalidOptions > 0 then -- 53
		Log( -- 54
			"Warn", -- 54
			("[LLMConfig] upgraded output budgets; preserved " .. tostring(invalidOptions)) .. " invalid custom options for correction" -- 54
		) -- 54
	end -- 54
end -- 9
return ____exports -- 9