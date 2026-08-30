import type { AgentSessionDetailResult } from "Agent/Session";

export const REMIX_HISTORY_ROUNDS = 10;

// A round starts with a user request and includes all replies until the next one.
// Keep this projection defensive for custom service adapters as well as the DB view.
export function remixHistory(detail: AgentSessionDetailResult) {
	if (!detail.success) return { messages: [], steps: [], hasEarlierMessages: false };
	let start = 0, rounds = 0;
	for (let i = detail.messages.length - 1; i >= 0; i--) {
		if (detail.messages[i].role !== "user") continue;
		rounds++;
		if (rounds === REMIX_HISTORY_ROUNDS) start = i;
		if (rounds > REMIX_HISTORY_ROUNDS) break;
	}
	if (rounds <= REMIX_HISTORY_ROUNDS) start = 0;
	return {
		messages: detail.messages.slice(start),
		steps: detail.steps.filter(s => s.taskId === detail.session.currentTaskId),
		hasEarlierMessages: detail.hasEarlierMessages === true || start > 0,
	};
}
