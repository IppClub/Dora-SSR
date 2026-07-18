-- [ts]: AgentRuntimePolicy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Utils = require("Agent.Utils") -- 3
local estimateTextTokens = ____Utils.estimateTextTokens -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 3
local Tools = require("Agent.Tools") -- 4
function ____exports.isEditBudgetExhausted(state) -- 14
	local mustCreateFreshEntry = state.freshProjectBuildPending == true and state.freshProjectCodeFile == nil and state.hasBuilt ~= true -- 15
	return state.unbuiltEdits == true and (state.editsSinceBuild or 0) >= 3 and not mustCreateFreshEntry -- 18
end -- 14
function ____exports.getUncoveredConversationMessages(messages, lastConsolidatedIndex) -- 23
	return __TS__ArraySlice(messages, lastConsolidatedIndex) -- 24
end -- 23
function ____exports.estimateConversationTokens(messages) -- 27
	local tokens = 0 -- 28
	do -- 28
		local i = 0 -- 29
		while i < #messages do -- 29
			local message = messages[i + 1] -- 30
			tokens = tokens + 8 -- 31
			tokens = tokens + estimateTextTokens(message.role or "") -- 32
			tokens = tokens + estimateTextTokens(message.content or "") -- 33
			tokens = tokens + estimateTextTokens(message.name or "") -- 34
			tokens = tokens + estimateTextTokens(message.tool_call_id or "") -- 35
			tokens = tokens + estimateTextTokens(message.reasoning_content or "") -- 36
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 37
			tokens = tokens + estimateTextTokens(toolCallsText or "") -- 38
			i = i + 1 -- 29
		end -- 29
	end -- 29
	return tokens -- 40
end -- 27
function ____exports.normalizeLineEndings(text) -- 43
	return table.concat( -- 44
		__TS__StringSplit( -- 44
			table.concat( -- 44
				__TS__StringSplit(text, "\r\n"), -- 44
				"\n" -- 44
			), -- 44
			"\r" -- 44
		), -- 44
		"\n" -- 44
	) -- 44
end -- 43
function ____exports.countOccurrences(text, needle) -- 47
	if needle == "" then -- 47
		return 0 -- 48
	end -- 48
	local count = 0 -- 49
	local start = 0 -- 50
	while start <= #text - #needle do -- 50
		local index = (string.find( -- 52
			text, -- 52
			needle, -- 52
			math.max(start + 1, 1), -- 52
			true -- 52
		) or 0) - 1 -- 52
		if index < 0 then -- 52
			break -- 53
		end -- 53
		count = count + 1 -- 54
		start = index + #needle -- 55
	end -- 55
	return count -- 57
end -- 47
function ____exports.containsWholeFileDuplicate(existing, replacement) -- 60
	local normalizedExisting = ____exports.normalizeLineEndings(existing) -- 61
	local normalizedReplacement = ____exports.normalizeLineEndings(replacement) -- 62
	if #normalizedExisting < 16 or #normalizedReplacement <= #normalizedExisting then -- 62
		return false -- 63
	end -- 63
	return ____exports.countOccurrences(normalizedReplacement, normalizedExisting) > 1 -- 64
end -- 60
function ____exports.successfulEditResult(workDir, path, base) -- 67
	local current = Tools.readFileRaw(workDir, path) -- 72
	local currentCharacters = current.success and type(current.content) == "string" and #current.content or 0 -- 73
	return __TS__ObjectAssign( -- 74
		{}, -- 74
		base, -- 75
		{ -- 74
			actualSaved = current.success, -- 76
			actualSavedCharacters = currentCharacters, -- 77
			currentFileExists = current.success, -- 77
			currentCharacters = currentCharacters, -- 78
			currentState = current.success and (("saved " .. tostring(currentCharacters)) .. " characters to ") .. path or "file state unavailable after edit: " .. sanitizeUTF8(current.message) -- 79
		} -- 79
	) -- 79
end -- 67
return ____exports -- 67
