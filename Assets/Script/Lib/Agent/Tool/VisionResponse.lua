-- [ts]: VisionResponse.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Utils = require("Agent.Utils") -- 2
local safeJsonDecode = ____Utils.safeJsonDecode -- 2
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 2
local function tokenCount(value) -- 10
	return type(value) == "number" and value >= 0 and value < math.huge and value == math.floor(value) -- 11
end -- 10
function ____exports.normalizeVisionUsage(value) -- 14
	if type(value) ~= "table" then -- 14
		return nil -- 15
	end -- 15
	local usage = value -- 16
	if not tokenCount(usage.prompt_tokens) or not tokenCount(usage.completion_tokens) then -- 16
		return nil -- 17
	end -- 17
	return { -- 18
		prompt_tokens = usage.prompt_tokens, -- 19
		completion_tokens = usage.completion_tokens, -- 20
		total_tokens = tokenCount(usage.total_tokens) and usage.total_tokens or usage.prompt_tokens + usage.completion_tokens -- 21
	} -- 21
end -- 14
--- Retain accounting even when a billed response is unusable; never retain reasoning or raw payloads.
function ____exports.parseVisionResponse(raw, expectedModel) -- 26
	local decoded = safeJsonDecode(raw) -- 27
	if type(decoded) ~= "table" then -- 27
		return {success = false, model = expectedModel, message = "Vision returned an invalid response"} -- 28
	end -- 28
	local response = decoded -- 29
	local usage = ____exports.normalizeVisionUsage(response.usage) -- 30
	local accounting = {model = expectedModel, usage = usage} -- 31
	if response.model ~= expectedModel then -- 31
		return __TS__ObjectAssign({}, accounting, {success = false, message = "Vision response model is missing or differs from the registered binding"}) -- 32
	end -- 32
	local choices = type(response.choices) == "table" and response.choices or ({}) -- 33
	local choice = type(choices[1]) == "table" and choices[1] or nil -- 34
	local message = type(choice and choice.message) == "table" and choice.message or nil -- 35
	local report = message and message.content -- 36
	local finishReason = type(choice and choice.finish_reason) == "string" and string.sub(choice.finish_reason, 1, 32) or nil -- 37
	if type(report) ~= "string" or __TS__StringTrim(report) == "" or finishReason ~= "stop" then -- 37
		local message = finishReason == "length" and "Vision report was truncated by the provider output limit before completing (finish_reason=length); narrow the question or analyze fewer images" or "Vision returned no complete report" -- 39
		return __TS__ObjectAssign({}, accounting, {success = false, finishReason = finishReason, message = message}) -- 42
	end -- 42
	return __TS__ObjectAssign( -- 44
		{}, -- 44
		accounting, -- 44
		{ -- 44
			success = true, -- 44
			report = sanitizeUTF8(string.sub(report, 1, 16000)), -- 44
			reportTruncated = #report > 16000 -- 44
		} -- 44
	) -- 44
end -- 26
return ____exports -- 26