-- [ts]: AgentToolGuards.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local ____exports = {} -- 1
local deny -- 1
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 2
local ____AgentToolValidation = require("Agent.AgentToolValidation") -- 3
local getAgentFileEditInputs = ____AgentToolValidation.getAgentFileEditInputs -- 3
function deny(code, message) -- 22
	return {denied = true, code = code, message = message} -- 23
end -- 23
function ____exports.getAgentFileEditPlanGuardDenial(context, edit) -- 73
	local path = AgentRuntimePolicy.normalizeAgentPath(edit.path) -- 77
	if context.workMode == "plan" and not AgentRuntimePolicy.isAgentPlanPath(path) then -- 77
		return deny( -- 79
			"PLAN_PATH_DENIED", -- 79
			(("edit_file operation " .. tostring(edit.index + 1)) .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR -- 79
		) -- 79
	end -- 79
	return nil -- 81
end -- 73
local function roleGuard(request) -- 26
	if __TS__ArrayIndexOf(request.definition.roles, request.context.role) >= 0 then -- 26
		return nil -- 27
	end -- 27
	return deny("TOOL_ROLE_DENIED", ((request.definition.name .. " is not available to ") .. request.context.role) .. " agents") -- 28
end -- 26
local function workModeGuard(request) -- 31
	if __TS__ArrayIndexOf(request.definition.workModes, request.context.workMode) >= 0 then -- 31
		return nil -- 32
	end -- 32
	return deny("TOOL_MODE_DENIED", ((request.definition.name .. " is not available in ") .. request.context.workMode) .. " mode") -- 33
end -- 31
local function disabledToolGuard(request) -- 36
	if __TS__ArrayIndexOf(request.context.disabledAgentTools, request.definition.name) < 0 then -- 36
		return nil -- 37
	end -- 37
	return deny("TOOL_DISABLED", request.definition.name .. " is disabled for this task") -- 38
end -- 36
local function planPathGuard(request) -- 41
	if request.context.workMode ~= "plan" then -- 41
		return nil -- 42
	end -- 42
	if request.definition.name ~= "edit_file" and request.definition.name ~= "delete_file" then -- 42
		return nil -- 43
	end -- 43
	if request.definition.name == "edit_file" then -- 43
		if __TS__ArrayIsArray(request.input.edits) then -- 43
			return nil -- 45
		end -- 45
		for ____, edit in ipairs(getAgentFileEditInputs(request.input)) do -- 46
			local denial = ____exports.getAgentFileEditPlanGuardDenial(request.context, edit) -- 47
			if denial ~= nil then -- 47
				return denial -- 48
			end -- 48
		end -- 48
		return nil -- 50
	end -- 50
	local path = AgentRuntimePolicy.normalizeAgentPath(AgentRuntimePolicy.getAgentDecisionPath(request.input)) -- 52
	if AgentRuntimePolicy.isAgentPlanPath(path) then -- 52
		return nil -- 55
	end -- 55
	return deny("PLAN_PATH_DENIED", (request.definition.name .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR) -- 56
end -- 41
local function protectedDocumentGuard(request) -- 59
	if request.definition.name ~= "delete_file" then -- 59
		return nil -- 60
	end -- 60
	local path = AgentRuntimePolicy.normalizeAgentPath(AgentRuntimePolicy.getAgentDecisionPath(request.input)) -- 61
	if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 61
		return deny("PROTECTED_AGENT_DOCUMENT", path .. " is a fixed living document and cannot be deleted") -- 65
	end -- 65
	if AgentRuntimePolicy.isMainAgentMemoryPath(path) then -- 65
		return deny("PROTECTED_AGENT_MEMORY", "Files under .agent/main are managed Agent memory and cannot be deleted with delete_file") -- 68
	end -- 68
	return nil -- 70
end -- 59
____exports.BUILT_IN_AGENT_TOOL_GUARDS = { -- 84
	roleGuard, -- 85
	workModeGuard, -- 86
	disabledToolGuard, -- 87
	planPathGuard, -- 88
	protectedDocumentGuard -- 89
} -- 89
function ____exports.runAgentToolGuards(request, guards) -- 92
	if guards == nil then -- 92
		guards = ____exports.BUILT_IN_AGENT_TOOL_GUARDS -- 94
	end -- 94
	for ____, guard in ipairs(guards) do -- 96
		local result = guard(request) -- 97
		if result ~= nil then -- 97
			return result -- 98
		end -- 98
	end -- 98
	return nil -- 100
end -- 92
return ____exports -- 92