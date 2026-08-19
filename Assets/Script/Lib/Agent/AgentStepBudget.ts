// @preview-file off clear

export function isFinalAgentDecisionTurn(agentStepCount: number, maxSteps: number): boolean {
	return agentStepCount + 1 >= maxSteps;
}

export function getRemainingAgentWorkSteps(agentStepCount: number, maxSteps: number): number {
	const remaining = maxSteps - agentStepCount - 1;
	return remaining > 0 ? remaining : 0;
}

export function getPlainTextCompletionBudgetState(agentStepCount: number, maxSteps: number): {
	outcome: "completed" | "partial";
	budgetExhausted: boolean;
} {
	const budgetExhausted = isFinalAgentDecisionTurn(agentStepCount, maxSteps);
	return {
		outcome: budgetExhausted ? "partial" : "completed",
		budgetExhausted,
	};
}
