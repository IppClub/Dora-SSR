-- [ts]: AgentStepBudget.ts
local ____exports = {} -- 1
function ____exports.isFinalAgentDecisionTurn(agentStepCount, maxSteps) -- 3
	return agentStepCount + 1 >= maxSteps -- 4
end -- 3
function ____exports.getRemainingAgentWorkSteps(agentStepCount, maxSteps) -- 7
	local remaining = maxSteps - agentStepCount - 1 -- 8
	return remaining > 0 and remaining or 0 -- 9
end -- 7
return ____exports -- 7