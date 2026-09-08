-- [ts]: VisionBinding.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
--- Increment when a fixed vision route or its request profile changes.
____exports.VISION_PROFILE_VERSION = 5 -- 5
--- Only exact, reviewed service endpoints may reuse the current credential.
function ____exports.resolveVisionBinding(config) -- 15
	if __TS__StringTrim(config.apiKey) == "" then -- 15
		return nil -- 16
	end -- 16
	local url = string.gsub( -- 17
		string.lower(__TS__StringTrim(config.url)), -- 17
		"/+$", -- 17
		"" -- 17
	) -- 17
	if url == "https://api.deepseek.com/chat/completions" or url == "https://api.deepseek.com/v1/chat/completions" then -- 17
		return {provider = "deepseek", model = "deepseek-v4-flash-vision-exp", url = "https://api.deepseek.com/v1/chat/completions", apiKey = config.apiKey} -- 19
	end -- 19
	if url == "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" then -- 19
		return {provider = "glm-coding-cn", model = "glm-5.3-flash", url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", apiKey = config.apiKey} -- 22
	end -- 22
	return nil -- 24
end -- 15
return ____exports -- 15