-- [ts]: Guards.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local ____exports = {} -- 1
local deny -- 1
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 2
local ____Validation = require("Agent.Tool.Validation") -- 3
local getAgentFileEditInputs = ____Validation.getAgentFileEditInputs -- 3
function deny(code, message) -- 22
	return {denied = true, code = code, message = message} -- 23
end -- 23
function ____exports.getAgentFileEditPlanGuardDenial(context, edit) -- 69
	local path = AgentRuntimePolicy.normalizeAgentPath(edit.path) -- 73
	if context.workMode == "plan" and not AgentRuntimePolicy.isAgentPlanPath(path) then -- 73
		return deny( -- 75
			"PLAN_PATH_DENIED", -- 75
			(("edit_file operation " .. tostring(edit.index + 1)) .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR -- 75
		) -- 75
	end -- 75
	return nil -- 77
end -- 69
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
	if request.definition.name ~= "edit_file" then -- 42
		return nil -- 43
	end -- 43
	if __TS__ArrayIsArray(request.input.edits) then -- 43
		return nil -- 44
	end -- 44
	for ____, edit in ipairs(getAgentFileEditInputs(request.input)) do -- 47
		local denial = ____exports.getAgentFileEditPlanGuardDenial(request.context, edit) -- 48
		if denial ~= nil then -- 48
			return denial -- 49
		end -- 49
	end -- 49
	return nil -- 51
end -- 41
local function protectedDocumentGuard(request) -- 54
	if request.definition.name ~= "edit_file" then -- 54
		return nil -- 55
	end -- 55
	if request.input.delete ~= true then -- 55
		return nil -- 56
	end -- 56
	local path = AgentRuntimePolicy.normalizeAgentPath(AgentRuntimePolicy.getAgentDecisionPath(request.input)) -- 57
	if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 57
		return deny("PROTECTED_AGENT_DOCUMENT", path .. " is a fixed living document and cannot be deleted") -- 61
	end -- 61
	if AgentRuntimePolicy.isMainAgentMemoryPath(path) then -- 61
		return deny("PROTECTED_AGENT_MEMORY", "Files under .agent/main are managed Agent memory and cannot be deleted with edit_file delete") -- 64
	end -- 64
	return nil -- 66
end -- 54
____exports.BUILT_IN_AGENT_TOOL_GUARDS = { -- 80
	roleGuard, -- 81
	workModeGuard, -- 82
	disabledToolGuard, -- 83
	planPathGuard, -- 84
	protectedDocumentGuard -- 85
} -- 85
function ____exports.runAgentToolGuards(request, guards) -- 88
	if guards == nil then -- 88
		guards = ____exports.BUILT_IN_AGENT_TOOL_GUARDS -- 90
	end -- 90
	for ____, guard in ipairs(guards) do -- 92
		local result = guard(request) -- 93
		if result ~= nil then -- 93
			return result -- 94
		end -- 94
	end -- 94
	return nil -- 96
end -- 88
return ____exports -- 88