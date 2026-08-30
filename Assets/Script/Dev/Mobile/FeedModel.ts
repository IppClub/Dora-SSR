export type FeedTab = "discover" | "local";
export type FeedAction = "none" | "previous" | "next" | "remix" | "play";

export interface FeedEntry {
	id: string;
	title: string;
	description: string;
	kind: FeedTab;
	fileName?: string;
	workDir?: string;
	bannerFile?: string;
	installed?: boolean;
}

export const normalizeFeedIndex = (index: number, count: number) => {
	if (count <= 0) return 0;
	return math.max(0, math.min(math.floor(index), count - 1));
};

export function resolveFeedLocation(local: FeedEntry[], discover: FeedEntry[], target?: FeedEntry): { tab: FeedTab; index: number } {
	if (target) {
		const preferred = target.kind === "discover" ? discover : local;
		const other = target.kind === "discover" ? local : discover;
		const match = (items: FeedEntry[]) => {
			// Paths identify the project even if its display name or list order changed.
			let index = target.fileName ? items.findIndex(item => item.fileName === target.fileName) : -1;
			if (index < 0 && target.workDir) index = items.findIndex(item => item.workDir === target.workDir);
			if (index < 0) index = items.findIndex(item => item.id === target.id && item.kind === target.kind);
			return index;
		};
		const index = match(preferred);
		if (index >= 0) return { tab: target.kind, index };
		const alternate = match(other);
		if (alternate >= 0) return { tab: target.kind === "discover" ? "local" : "discover", index: alternate };
	}
	return { tab: local.length > 0 ? "local" : "discover", index: 0 };
}

export const getReusableCardIndices = (index: number, count: number) => {
	if (count <= 0) return [];
	const current = normalizeFeedIndex(index, count);
	const result: number[] = [];
	if (current > 0) result.push(current - 1);
	result.push(current);
	if (current + 1 < count) result.push(current + 1);
	return result;
};

export const resolveFeedGesture = (
	dx: number,
	dy: number,
	width: number,
	height: number,
	controlCaptured = false,
): FeedAction => {
	if (controlCaptured) return "none";
	const absX = math.abs(dx);
	const absY = math.abs(dy);
	if (absX < 18 && absY < 18) return "none";
	if (absX > absY * 1.2) {
		if (absX < math.max(64, width * 0.18)) return "none";
		return dx > 0 ? "remix" : "play";
	}
	if (absY < math.max(72, height * 0.14)) return "none";
	return dy > 0 ? "next" : "previous";
};

export const stableCoverColor = (id: string) => {
	let hash = 17;
	for (let i = 0; i < id.length; i++) hash = (hash * 31 + id.charCodeAt(i)) % 9973;
	const palette = [0xff203049, 0xff273c35, 0xff3a2948, 0xff463128, 0xff263c48, 0xff3f3540];
	return palette[hash % palette.length];
};

export const getCoverScales = (sourceWidth: number, sourceHeight: number, targetWidth: number, targetHeight: number) => {
	if (sourceWidth <= 0 || sourceHeight <= 0 || targetWidth <= 0 || targetHeight <= 0) {
		return { contain: 1, cover: 1 };
	}
	return {
		contain: math.min(targetWidth / sourceWidth, targetHeight / sourceHeight),
		cover: math.max(targetWidth / sourceWidth, targetHeight / sourceHeight),
	};
};

export const resolveDiscoverRefreshTab = (
	currentTab: FeedTab,
	userSelectedTab: boolean,
	previousDiscoverCount: number,
	refreshedDiscoverCount: number,
	localCount = 0,
): FeedTab => !userSelectedTab && localCount === 0 && previousDiscoverCount === 0 && refreshedDiscoverCount > 0
	? "discover"
	: currentTab;
