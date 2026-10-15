type AgentRenderKind = "message" | "step";

const enabled = new URLSearchParams(window.location.search).get("doraPerf") === "1";
const renderCounts = new Map<string, number>();

export function recordAgentRowRender(kind: AgentRenderKind, id: number): number | undefined {
	if (!enabled) return undefined;
	const key = `${kind}:${id}`;
	const count = (renderCounts.get(key) ?? 0) + 1;
	renderCounts.set(key, count);
	return count;
}
