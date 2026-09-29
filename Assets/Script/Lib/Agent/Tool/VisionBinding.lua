-- [ts]: VisionBinding.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
--- Increment when a fixed vision route or its request profile changes.
____exports.VISION_PROFILE_VERSION = 6 -- 5
--- Only exact, reviewed service endpoints may reuse the current credential.
function ____exports.resolveVisionBinding(config) -- 16
	if __TS__StringTrim(config.apiKey) == "" then -- 16
		return nil -- 17
	end -- 17
	if config.studioGateway == true then -- 17
		local vision = config.studioVision -- 19
		if not vision or config.apiKey ~= "studio-agent" then -- 19
			return nil -- 20
		end -- 20
		local expectedModel = vision.provider == "deepseek" and "deepseek-flash" or (vision.provider == "glm-coding-cn" and "glm-5.3-flash" or nil) -- 21
		if not expectedModel or vision.model ~= expectedModel then -- 21
			return nil -- 23
		end -- 23
		local url = string.gsub( -- 24
			__TS__StringTrim(vision.url), -- 24
			"/+$", -- 24
			"" -- 24
		) -- 24
		if not __TS__StringStartsWith(url, "https://") or not __TS__StringIncludes(url, "/agent-host/") or not __TS__StringIncludes(url, "/vision/") then -- 24
			return nil -- 25
		end -- 25
		return { -- 26
			provider = vision.provider, -- 26
			model = vision.model, -- 26
			url = url, -- 26
			apiKey = config.apiKey, -- 26
			studioGateway = true -- 26
		} -- 26
	end -- 26
	local url = string.gsub( -- 28
		string.lower(__TS__StringTrim(config.url)), -- 28
		"/+$", -- 28
		"" -- 28
	) -- 28
	if url == "https://api.deepseek.com/chat/completions" or url == "https://api.deepseek.com/v1/chat/completions" then -- 28
		return {provider = "deepseek", model = "deepseek-flash", url = "https://api.deepseek.com/v1/chat/completions", apiKey = config.apiKey} -- 30
	end -- 30
	if url == "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" then -- 30
		return {provider = "glm-coding-cn", model = "glm-5.3-flash", url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", apiKey = config.apiKey} -- 33
	end -- 33
	return nil -- 35
end -- 16
return ____exports -- 16