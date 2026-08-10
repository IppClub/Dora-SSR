// @preview-file off clear

export function isFinalAgentDecisionTurn(agentStepCount: number, maxSteps: number): boolean {
	return agentStepCount + 1 >= maxSteps;
}

export function getRemainingAgentWorkSteps(agentStepCount: number, maxSteps: number): number {
	const remaining = maxSteps - agentStepCount - 1;
	return remaining > 0 ? remaining : 0;
}
