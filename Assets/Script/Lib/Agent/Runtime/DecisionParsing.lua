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
	return {success = true, kind = "plain_text_completion", content = content, reasoningContent = reasoningContent} -- 80
end -- 62
function ____exports.parseDecisionObject(rawObj) -- 88
	if type(rawObj.tool) ~= "string" then -- 88
		return {success = false, message = "missing tool"} -- 89
	end -- 89
	local tool = rawObj.tool -- 90
	if not AgentToolRegistry.isKnownToolName(tool) then -- 90
		return {success = false, message = "unknown tool: " .. tool} -- 92
	end -- 92
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 94
	if not reason or reason == "" then -- 94
		return {success = false, message = tool .. " requires top-level reason"} -- 98
	end -- 98
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 100
	return {success = true, tool = tool, params = params, reason = reason} -- 101
end -- 88
function ____exports.parseDecisionToolCall(functionName, rawObj) -- 109
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 109
		return {success = false, message = "unknown tool: " .. functionName} -- 111
	end -- 111
	if rawObj == nil then -- 111
		return {success = true, tool = functionName, params = {}} -- 114
	end -- 114
	if not isRecord(rawObj) then -- 114
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 117
	end -- 117
	return {success = true, tool = functionName, params = rawObj} -- 119
end -- 109
function ____exports.parseToolCallArguments(functionName, argsText) -- 126
	local trimmedArgs = __TS__StringTrim(argsText) -- 127
	if trimmedArgs == "" then -- 127
		return {} -- 129
	end -- 129
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 131
	if err ~= nil or rawObj == nil then -- 131
		return { -- 133
			success = false, -- 134
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 135
			raw = argsText -- 136
		} -- 136
	end -- 136
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 139
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 139
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 141
	end -- 141
	return rawObj -- 147
end -- 126
____exports.getDecisionPath = getAgentDecisionPath -- 150
function ____exports.validateDecision(tool, params) -- 152
	local definition = AgentToolRegistry.getToolDefinition(tool) -- 156
	if definition == nil then -- 156
		return {success = false, message = "unknown tool: " .. tool} -- 157
	end -- 157
	local validateInput = definition.validateInput -- 158
	local validation = validateInput and validateInput(params) -- 159
	if validation == nil then -- 159
		return {success = true, params = params} -- 160
	end -- 160
	return validation.success and ({success = true, params = validation.value}) or validation -- 161
end -- 152
function ____exports.validateCompletionForRole(_role, _tool, _params) -- 166
	return {success = true} -- 172
end -- 166
return ____exports -- 166