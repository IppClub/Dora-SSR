-- [ts]: VisionBinding.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
--- Increment when a fixed vision route or its request profile changes.
____exports.VISION_PROFILE_VERSION = 8 -- 5
____exports.VISION_UNAVAILABLE_MESSAGE = "没有可用的视觉配置。请在 Agent 设置中填写当前配置的视觉模型，或保存受支持的官方 DeepSeek / GLM Coding Plan 配置。" -- 7
--- Default routes stay fixed; an explicit model opts into the current configured endpoint.
function ____exports.resolveVisionBinding(config) -- 19
	if __TS__StringTrim(config.apiKey) == "" then -- 19
		return nil -- 20
	end -- 20
	if config.studioGateway == true then -- 20
		local vision = config.studioVision -- 22
		if not vision or config.apiKey ~= "studio-agent" then -- 22
			return nil -- 23
		end -- 23
		local expectedModel = vision.provider == "deepseek" and "deepseek-flash" or (vision.provider == "glm-coding-cn" and "glm-5.3-flash" or nil) -- 24
		if not expectedModel or vision.model ~= expectedModel then -- 24
			return nil -- 26
		end -- 26
		local url = string.gsub( -- 27
			__TS__StringTrim(vision.url), -- 27
			"/+$", -- 27
			"" -- 27
		) -- 27
		if not __TS__StringStartsWith(url, "https://") or not __TS__StringIncludes(url, "/agent-host/") or not __TS__StringIncludes(url, "/vision/") then -- 27
			return nil -- 28
		end -- 28
		return { -- 29
			provider = vision.provider, -- 29
			model = vision.model, -- 29
			url = url, -- 29
			apiKey = config.apiKey, -- 29
			studioGateway = true -- 29
		} -- 29
	end -- 29
	local ____opt_0 = config.customOptions -- 29
	local configuredModel = ____opt_0 and ____opt_0.visionModel -- 31
	local customModel = type(configuredModel) == "string" and __TS__StringTrim(configuredModel) or "" -- 32
	local url = string.gsub( -- 33
		string.lower(__TS__StringTrim(config.url)), -- 33
		"/+$", -- 33
		"" -- 33
	) -- 33
	if url == "https://api.deepseek.com/chat/completions" or url == "https://api.deepseek.com/v1/chat/completions" then -- 33
		return { -- 35
			provider = "deepseek", -- 35
			model = customModel ~= "" and customModel or "deepseek-flash", -- 35
			url = "https://api.deepseek.com/v1/chat/completions", -- 35
			apiKey = config.apiKey, -- 35
			customModel = customModel ~= "" -- 35
		} -- 35
	end -- 35
	if url == "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" then -- 35
		return { -- 38
			provider = "glm-coding-cn", -- 38
			model = customModel ~= "" and customModel or "glm-5.3-flash", -- 38
			url = url, -- 38
			apiKey = config.apiKey, -- 38
			customModel = customModel ~= "" -- 38
		} -- 38
	end -- 38
	if customModel ~= "" and (__TS__StringStartsWith(url, "https://") or __TS__StringStartsWith(url, "http://")) then -- 38
		return { -- 41
			provider = "custom", -- 41
			model = customModel, -- 41
			url = __TS__StringTrim(config.url), -- 41
			apiKey = config.apiKey, -- 41
			customModel = true -- 41
		} -- 41
	end -- 41
	return nil -- 43
end -- 19
function ____exports.resolveTaskVisionBinding(config, getSavedConfigs) -- 46
	local current = ____exports.resolveVisionBinding(config) -- 47
	local ____opt_2 = config.customOptions -- 47
	local customModel = ____opt_2 and ____opt_2.visionModel -- 48
	if current or config.studioGateway or type(customModel) == "string" and __TS__StringTrim(customModel) ~= "" then -- 48
		return current -- 50
	end -- 50
	for ____, candidate in ipairs(getSavedConfigs()) do -- 52
		local binding = ____exports.resolveVisionBinding(candidate) -- 53
		if binding and binding.provider ~= "custom" then -- 53
			return binding -- 54
		end -- 54
	end -- 54
	return nil -- 56
end -- 46
return ____exports -- 46