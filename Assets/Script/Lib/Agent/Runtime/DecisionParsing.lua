-- [ts]: DecisionParsing.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local ____exports = {} -- 1
local AgentUtils = require("Agent.Utils") -- 1
local AgentToolRegistry = require("Agent.Tool.Registry") -- 3
local ____Policy = require("Agent.Runtime.Policy") -- 5
local getAgentDecisionPath = ____Policy.getAgentDecisionPath -- 5
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
function ____exports.isDecisionBatchSuccess(result) -- 50
	return result.kind == "batch" -- 51
end -- 50
function ____exports.isDecisionLoopContinue(result) -- 54
	return result.success == true and result.kind == "continue" -- 55
end -- 54
function ____exports.isDecisionPlainTextCompletion(result) -- 58
	return result.success == true and result.kind == "plain_text_completion" -- 59
end -- 58
function ____exports.classifyToolCallingTurnWithoutCalls(role, finishReason, messageContent, reasoningContent) -- 62
	if finishReason == "length" then -- 62
		return { -- 69
			success = true, -- 70
			kind = "continue", -- 71
			reason = "length", -- 72
			content = messageContent, -- 73
			reasoningContent = reasoningContent -- 74
		} -- 74
	end -- 74
	local ____opt_0 = messageContent -- 74
	local content = ____opt_0 and __TS__StringTrim(messageContent) or "" -- 77
	if content == "" then -- 77
		return nil -- 78
	end -- 78
	if role == "sub" then -- 78
		return {success = false, message = "sub agents must call finish with structured completion metadata; plain-text completion is not accepted", raw = content} -- 80
	end -- 80
	return {success = true, kind = "plain_text_completion", content = content, reasoningContent = reasoningContent} -- 86
end -- 62
function ____exports.parseDecisionObject(rawObj) -- 94
	if type(rawObj.tool) ~= "string" then -- 94
		return {success = false, message = "missing tool"} -- 95
	end -- 95
	local tool = rawObj.tool -- 96
	if not AgentToolRegistry.isKnownToolName(tool) then -- 96
		return {success = false, message = "unknown tool: " .. tool} -- 98
	end -- 98
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 100
	if tool ~= "finish" and (not reason or reason == "") then -- 100
		return {success = false, message = tool .. " requires top-level reason"} -- 104
	end -- 104
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 106
	return {success = true, tool = tool, params = params, reason = reason} -- 107
end -- 94
function ____exports.parseDecisionToolCall(functionName, rawObj) -- 115
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 115
		return {success = false, message = "unknown tool: " .. functionName} -- 117
	end -- 117
	if rawObj == nil then -- 117
		return {success = true, tool = functionName, params = {}} -- 120
	end -- 120
	if not isRecord(rawObj) then -- 120
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 123
	end -- 123
	return {success = true, tool = functionName, params = rawObj} -- 125
end -- 115
function ____exports.parseToolCallArguments(functionName, argsText) -- 132
	local trimmedArgs = __TS__StringTrim(argsText) -- 133
	if trimmedArgs == "" then -- 133
		return {} -- 135
	end -- 135
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 137
	if err ~= nil or rawObj == nil then -- 137
		return { -- 139
			success = false, -- 140
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 141
			raw = argsText -- 142
		} -- 142
	end -- 142
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 145
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 145
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 147
	end -- 147
	return rawObj -- 153
end -- 132
____exports.getDecisionPath = getAgentDecisionPath -- 156
function ____exports.validateDecision(tool, params) -- 158
	local definition = AgentToolRegistry.getToolDefinition(tool) -- 162
	if definition == nil then -- 162
		return {success = false, message = "unknown tool: " .. tool} -- 163
	end -- 163
	local validateInput = definition.validateInput -- 164
	local validation = validateInput and validateInput(params) -- 165
	if validation == nil then -- 165
		return {success = true, params = params} -- 166
	end -- 166
	return validation.success and ({success = true, params = validation.value}) or validation -- 167
end -- 158
function ____exports.validateCompletionForRole(role, tool, params) -- 172
	if tool ~= "finish" then -- 172
		return {success = true} -- 177
	end -- 177
	if role ~= "sub" then -- 177
		return {success = false, message = "finish is reserved for sub agents"} -- 178
	end -- 178
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 178
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 180
	end -- 180
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 182
	do -- 182
		local i = 0 -- 183
		while i < #requiredArrays do -- 183
			local name = requiredArrays[i + 1] -- 184
			if not isArray(params[name]) then -- 184
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 186
			end -- 186
			i = i + 1 -- 183
		end -- 183
	end -- 183
	return {success = true} -- 189
end -- 172
return ____exports -- 172