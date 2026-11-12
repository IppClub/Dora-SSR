-- [ts]: VisionBinding.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
--- Increment when a fixed vision route or its request profile changes.
____exports.VISION_PROFILE_VERSION = 7 -- 5
____exports.VISION_UNAVAILABLE_MESSAGE = "当前大模型服务没有可用视觉通道。请检查 Agent 设置中的模型服务与 API 接口地址。" -- 7
--- Only exact, reviewed service endpoints may reuse the current credential.
function ____exports.resolveVisionBinding(config) -- 18
	if __TS__StringTrim(config.apiKey) == "" then -- 18
		return nil -- 19
	end -- 19
	if config.studioGateway == true then -- 19
		local vision = config.studioVision -- 21
		if not vision or config.apiKey ~= "studio-agent" then -- 21
			return nil -- 22
		end -- 22
		local expectedModel = vision.provider == "deepseek" and "deepseek-flash" or (vision.provider == "glm-coding-cn" and "glm-5.3-flash" or nil) -- 23
		if not expectedModel or vision.model ~= expectedModel then -- 23
			return nil -- 25
		end -- 25
		local url = string.gsub( -- 26
			__TS__StringTrim(vision.url), -- 26
			"/+$", -- 26
			"" -- 26
		) -- 26
		if not __TS__StringStartsWith(url, "https://") or not __TS__StringIncludes(url, "/agent-host/") or not __TS__StringIncludes(url, "/vision/") then -- 26
			return nil -- 27
		end -- 27
		return { -- 28
			provider = vision.provider, -- 28
			model = vision.model, -- 28
			url = url, -- 28
			apiKey = config.apiKey, -- 28
			studioGateway = true -- 28
		} -- 28
	end -- 28
	local url = string.gsub( -- 30
		string.lower(__TS__StringTrim(config.url)), -- 30
		"/+$", -- 30
		"" -- 30
	) -- 30
	if url == "https://api.deepseek.com/chat/completions" or url == "https://api.deepseek.com/v1/chat/completions" then -- 30
		return {provider = "deepseek", model = "deepseek-flash", url = "https://api.deepseek.com/v1/chat/completions", apiKey = config.apiKey} -- 32
	end -- 32
	if url == "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" then -- 32
		return {provider = "glm-coding-cn", model = "glm-5.3-flash", url = url, apiKey = config.apiKey} -- 35
	end -- 35
	return nil -- 37
end -- 18
return ____exports -- 18