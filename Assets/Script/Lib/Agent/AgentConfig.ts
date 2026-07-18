// @preview-file off clear

export const AGENT_DEFAULTS = {
	maxSteps: 100,
	llmMaxTry: 5,
	llmTemperature: 0.1,
	llmMaxTokens: 8192,
	delegatedForegroundBatchLimit: 3,
	turnBoundaryCompressionRatio: 0.6,
	turnBoundaryHighMessageCompressionRatio: 0.4,
	turnBoundaryHighMessageCount: 64,
};

export const AGENT_LIMITS = {
	userPromptMaxChars: 12000,
	historyReadFileMaxChars: 12000,
	historyReadFileMaxLines: 300,
	readFileDefaultLimit: 300,
	historySearchFilesMaxMatches: 20,
	historySearchDoraApiMaxMatches: 12,
	historyListFilesMaxEntries: 200,
	historyBuildMaxMessages: 50,
	historyBuildMessageMaxChars: 1200,
	searchDoraApiLimitMax: 20,
	searchFilesLimitDefault: 20,
	listFilesMaxEntriesDefault: 200,
	searchPreviewContext: 80,
};

export function getTurnBoundaryCompressionThresholds(contextWindow: number): {
	defaultTokens: number;
	highMessageTokens: number;
} {
	const normalizedContextWindow = math.max(1, math.floor(contextWindow));
	return {
		defaultTokens: math.floor(normalizedContextWindow * AGENT_DEFAULTS.turnBoundaryCompressionRatio),
		highMessageTokens: math.floor(normalizedContextWindow * AGENT_DEFAULTS.turnBoundaryHighMessageCompressionRatio),
	};
}
