// Mobile UI always uses the former large-text scale; ignore legacy preferences.
export const mobileFontScale = 1.16;
export function getMobileLargeText() {
	return true;
}

// Retained for callers of older development tools; there is no small-text mode.
export function setMobileLargeText(_enabled: boolean) {}
