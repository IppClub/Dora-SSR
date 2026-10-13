/** Complete decision responses only; provider IDs and streaming chunks are excluded. */
export interface DecisionOutput {
	content?: string | null;
	reasoning_content?: string | null;
	tool_calls?: { function?: { name?: string; arguments?: string } }[];
}

export function decisionOutputKey(message: DecisionOutput): string {
	const parts = [message.content ?? "", message.reasoning_content ?? ""];
	for (const call of message.tool_calls ?? []) {
		parts.push(call.function?.name ?? "", call.function?.arguments ?? "");
	}
	// Length prefixes preserve exact text, order, whitespace and argument spelling.
	return parts.map(part => `${part.length}:${part}`).join("");
}

/** One recovery per identical output in this task; explicit continuation starts fresh. */
export class RepeatedOutputRecovery {
	private previous?: string;
	private recovered = new Set<string>();

	observe(message: DecisionOutput): "accept" | "compact" | "pause" {
		const key = decisionOutputKey(message);
		const repeated = key === this.previous;
		this.previous = key;
		if (!repeated) return "accept";
		if (this.recovered.has(key)) return "pause";
		this.recovered.add(key);
		return "compact";
	}

}
