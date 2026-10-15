export interface AgentRenderWindow<T> {
	items: T[];
	hiddenCount: number;
	revealCount: number;
}

export function getAgentTailRenderWindow<T>(
	items: T[],
	visibleCount: number,
	revealBatchSize: number,
): AgentRenderWindow<T> {
	const boundedVisibleCount = Math.max(0, Math.floor(visibleCount));
	const boundedRevealBatchSize = Math.max(1, Math.floor(revealBatchSize));
	const hiddenCount = Math.max(0, items.length - boundedVisibleCount);
	return {
		items: hiddenCount > 0
			? (boundedVisibleCount === 0 ? [] : items.slice(-boundedVisibleCount))
			: items,
		hiddenCount,
		revealCount: Math.min(boundedRevealBatchSize, hiddenCount),
	};
}
